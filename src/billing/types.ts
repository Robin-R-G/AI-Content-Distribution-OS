export type BillingInterval = 'monthly' | 'yearly';

export type SubscriptionStatus = 'active' | 'trialing' | 'past_due' | 'canceled' | 'unpaid' | 'incomplete';

export interface Plan {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  interval: BillingInterval;
  features: PlanFeature[];
  limits: Record<string, number>;
  isPopular?: boolean;
}

export interface PlanFeature {
  id: string;
  name: string;
  description: string;
  included: boolean;
  limit?: number;
}

export interface Subscription {
  id: string;
  orgId: string;
  planId: string;
  status: SubscriptionStatus;
  currentPeriodStart: Date;
  currentPeriodEnd: Date;
  cancelAt?: Date;
  canceledAt?: Date;
  trialEnd?: Date;
  paymentMethodId?: string;
  metadata?: Record<string, unknown>;
  createdAt: Date;
  updatedAt: Date;
}

export interface Invoice {
  id: string;
  orgId: string;
  subscriptionId?: string;
  amount: number;
  currency: string;
  status: 'draft' | 'open' | 'paid' | 'void' | 'uncollectible';
  dueDate: Date;
  paidAt?: Date;
  items: InvoiceItem[];
  pdfUrl?: string;
  createdAt: Date;
}

export interface InvoiceItem {
  description: string;
  amount: number;
  quantity: number;
  unitPrice: number;
}

export interface Payment {
  id: string;
  orgId: string;
  invoiceId?: string;
  amount: number;
  currency: string;
  status: 'pending' | 'succeeded' | 'failed' | 'refunded';
  paymentMethodId: string;
  failureReason?: string;
  createdAt: Date;
}

export interface PaymentMethod {
  id: string;
  orgId: string;
  type: 'card' | 'bank_account' | 'paypal';
  last4: string;
  brand?: string;
  expMonth?: number;
  expYear?: number;
  isDefault: boolean;
  createdAt: Date;
}

export interface CreditBalance {
  orgId: string;
  credits: number;
  lifetimeCredits: number;
  lifetimeUsed: number;
  lastUpdated: Date;
}

export interface UsageRecord {
  id: string;
  orgId: string;
  metric: string;
  quantity: number;
  timestamp: Date;
}

export interface Coupon {
  id: string;
  code: string;
  type: 'percentage' | 'fixed';
  value: number;
  maxUses?: number;
  usedCount: number;
  validFrom: Date;
  validUntil: Date;
  active: boolean;
}
