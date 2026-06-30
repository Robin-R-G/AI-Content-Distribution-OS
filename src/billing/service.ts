import { v4 as uuidv4 } from 'uuid';
import type {
  Subscription,
  Invoice,
  Payment,
  PaymentMethod,
  CreditBalance,
  UsageRecord,
  Coupon,
  Plan,
} from './types';

export class BillingService {
  private db: any;
  private stripe: any;

  constructor(db: any, stripe?: any) {
    this.db = db;
    this.stripe = stripe;
  }

  async createSubscription(orgId: string, planId: string, paymentMethodId: string): Promise<Subscription> {
    const plan = await this.db.plan.findUnique({ where: { id: planId } });
    if (!plan) throw new Error('Plan not found');

    if (this.stripe) {
      const org = await this.db.organization.findUnique({ where: { id: orgId } });
      const customer = await this.stripe.customers.create({ email: org?.email, metadata: { orgId } });
      const stripeSubscription = await this.stripe.subscriptions.create({
        customer: customer.id,
        items: [{ price: plan.stripePriceId }],
        default_payment_method: paymentMethodId,
        trial_period_days: 14,
      });

      return this.db.subscription.create({
        data: {
          id: uuidv4(), orgId, planId, status: 'trialing',
          currentPeriodStart: new Date(stripeSubscription.current_period_start * 1000),
          currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000),
          trialEnd: new Date(stripeSubscription.trial_end * 1000),
          paymentMethodId, createdAt: new Date(), updatedAt: new Date(),
        },
      });
    }

    return this.db.subscription.create({
      data: {
        id: uuidv4(), orgId, planId, status: 'active',
        currentPeriodStart: new Date(), currentPeriodEnd: new Date(Date.now() + 30 * 86400000),
        paymentMethodId, createdAt: new Date(), updatedAt: new Date(),
      },
    });
  }

  async upgradePlan(orgId: string, newPlanId: string): Promise<Subscription> {
    const sub = await this.db.subscription.findFirst({ where: { orgId, status: { in: ['active', 'trialing'] } } });
    if (!sub) throw new Error('No active subscription');

    const newPlan = await this.db.plan.findUnique({ where: { id: newPlanId } });
    if (!newPlan) throw new Error('Plan not found');

    if (this.stripe && sub.stripeSubscriptionId) {
      const items = await this.stripe.subscriptions.retrieve(sub.stripeSubscriptionId);
      await this.stripe.subscriptions.update(sub.stripeSubscriptionId, {
        items: [{ id: items.items.data[0].id, price: newPlan.stripePriceId }],
        proration_behavior: 'always_invoice',
      });
    }

    return this.db.subscription.update({
      where: { id: sub.id },
      data: { planId: newPlanId, updatedAt: new Date() },
    });
  }

  async downgradePlan(orgId: string, newPlanId: string): Promise<Subscription> {
    const sub = await this.db.subscription.findFirst({ where: { orgId, status: 'active' } });
    if (!sub) throw new Error('No active subscription');

    return this.db.subscription.update({
      where: { id: sub.id },
      data: { planId: newPlanId, updatedAt: new Date() },
    });
  }

  async cancelSubscription(orgId: string): Promise<Subscription> {
    const sub = await this.db.subscription.findFirst({ where: { orgId, status: { in: ['active', 'trialing'] } } });
    if (!sub) throw new Error('No active subscription');

    if (this.stripe && sub.stripeSubscriptionId) {
      await this.stripe.subscriptions.update(sub.stripeSubscriptionId, { cancel_at_period_end: true });
    }

    return this.db.subscription.update({
      where: { id: sub.id },
      data: { cancelAt: sub.currentPeriodEnd, updatedAt: new Date() },
    });
  }

  async getSubscription(orgId: string): Promise<Subscription | null> {
    return this.db.subscription.findFirst({ where: { orgId }, include: { plan: true } });
  }

  async getInvoices(orgId: string, filters?: { status?: string; limit?: number; offset?: number }): Promise<Invoice[]> {
    return this.db.invoice.findMany({
      where: { orgId, ...(filters?.status ? { status: filters.status } : {}) },
      orderBy: { createdAt: 'desc' },
      take: filters?.limit ?? 50,
      skip: filters?.offset ?? 0,
    });
  }

  async getInvoice(invoiceId: string): Promise<Invoice> {
    const invoice = await this.db.invoice.findUnique({ where: { id: invoiceId }, include: { items: true } });
    if (!invoice) throw new Error('Invoice not found');
    return invoice;
  }

  async addPaymentMethod(orgId: string, paymentMethodId: string): Promise<PaymentMethod> {
    if (this.stripe) {
      const pm = await this.db.paymentMethod.findUnique({ where: { id: paymentMethodId } });
      if (!pm) throw new Error('Payment method not found');
    }

    return this.db.paymentMethod.update({
      where: { id: paymentMethodId },
      data: { orgId, isDefault: !(await this.db.paymentMethod.findFirst({ where: { orgId, isDefault: true } })) },
    });
  }

  async removePaymentMethod(orgId: string, paymentMethodId: string): Promise<void> {
    const pm = await this.db.paymentMethod.findFirst({ where: { id: paymentMethodId, orgId } });
    if (!pm) throw new Error('Payment method not found');
    if (pm.isDefault) throw new Error('Cannot remove default payment method');

    if (this.stripe) await this.stripe.paymentMethods.detach(pm.stripePaymentMethodId);
    await this.db.paymentMethod.delete({ where: { id: paymentMethodId } });
  }

  async purchaseCredits(orgId: string, amount: number): Promise<CreditBalance> {
    const balance = await this.db.creditBalance.findUnique({ where: { orgId } });
    if (!balance) throw new Error('Credit balance not found');

    if (this.stripe) {
      const org = await this.db.organization.findUnique({ where: { id: orgId } });
      await this.stripe.paymentIntents.create({ amount: amount * 100, currency: 'usd', customer: org?.stripeCustomerId });
    }

    return this.db.creditBalance.update({
      where: { orgId },
      data: { credits: balance.credits + amount, lifetimeCredits: balance.lifetimeCredits + amount, lastUpdated: new Date() },
    });
  }

  async getCredits(orgId: string): Promise<CreditBalance> {
    let balance = await this.db.creditBalance.findUnique({ where: { orgId } });
    if (!balance) {
      balance = await this.db.creditBalance.create({
        data: { orgId, credits: 0, lifetimeCredits: 0, lifetimeUsed: 0, lastUpdated: new Date() },
      });
    }
    return balance;
  }

  async recordUsage(orgId: string, metric: string, quantity: number): Promise<UsageRecord> {
    return this.db.usageRecord.create({
      data: { id: uuidv4(), orgId, metric, quantity, timestamp: new Date() },
    });
  }

  async getUsage(orgId: string, period: { start: Date; end: Date }): Promise<UsageRecord[]> {
    return this.db.usageRecord.findMany({
      where: { orgId, timestamp: { gte: period.start, lte: period.end } },
      orderBy: { timestamp: 'desc' },
    });
  }
}
