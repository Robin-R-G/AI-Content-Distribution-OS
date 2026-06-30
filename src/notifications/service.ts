import { v4 as uuidv4 } from 'uuid';
import type {
  Notification,
  NotificationPreference,
  NotificationType,
  NotificationChannel,
  EmailTemplate,
  PushPayload,
} from './types';

export class NotificationService {
  private db: any;
  private redis: any;
  private emailProvider: any;
  private pushProvider: any;

  constructor(db: any, redis: any, emailProvider?: any, pushProvider?: any) {
    this.db = db;
    this.redis = redis;
    this.emailProvider = emailProvider;
    this.pushProvider = pushProvider;
  }

  async send(
    userId: string,
    type: NotificationType,
    title: string,
    body: string,
    data?: Record<string, unknown>
  ): Promise<Notification> {
    const preferences = await this.getPreferences(userId);
    const enabledChannels = preferences.filter((p) => p.type === type && p.enabled).map((p) => p.channel);

    const notification = await this.db.notification.create({
      data: {
        id: uuidv4(),
        userId,
        type,
        title,
        body,
        data,
        read: false,
        channel: 'in_app',
        createdAt: new Date(),
      },
    });

    await this.redis.publish('notifications:new', JSON.stringify(notification));

    for (const channel of enabledChannels) {
      if (channel === 'email') await this.sendEmailFromNotification(userId, title, body, data);
      if (channel === 'push') await this.sendPushFromNotification(userId, { title, body, data });
      if (channel === 'webhook') await this.sendWebhooks(userId, type, data);
    }

    return notification;
  }

  async sendBulk(
    userIds: string[],
    type: NotificationType,
    title: string,
    body: string,
    data?: Record<string, unknown>
  ): Promise<Notification[]> {
    const notifications = await Promise.all(
      userIds.map((userId) => this.send(userId, type, title, body, data))
    );
    return notifications;
  }

  async getNotifications(
    userId: string,
    filters?: { type?: NotificationType; read?: boolean; limit?: number; offset?: number }
  ): Promise<Notification[]> {
    const where: any = { userId };
    if (filters?.type) where.type = filters.type;
    if (filters?.read !== undefined) where.read = filters.read;

    return this.db.notification.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: filters?.limit ?? 50,
      skip: filters?.offset ?? 0,
    });
  }

  async markAsRead(notificationId: string): Promise<void> {
    await this.db.notification.update({
      where: { id: notificationId },
      data: { read: true, readAt: new Date() },
    });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.db.notification.updateMany({
      where: { userId, read: false },
      data: { read: true, readAt: new Date() },
    });
  }

  async getPreferences(userId: string): Promise<NotificationPreference[]> {
    return this.db.notificationPreference.findMany({ where: { userId } });
  }

  async updatePreferences(userId: string, preferences: Partial<NotificationPreference>[]): Promise<void> {
    for (const pref of preferences) {
      await this.db.notificationPreference.upsert({
        where: { userId_type_channel: { userId, type: pref.type!, channel: pref.channel! } },
        update: { enabled: pref.enabled, frequency: pref.frequency },
        create: { userId, type: pref.type!, channel: pref.channel!, enabled: pref.enabled ?? true, frequency: pref.frequency ?? 'immediate' },
      });
    }
  }

  async sendEmail(to: string, template: EmailTemplate, data: Record<string, unknown>): Promise<void> {
    if (!this.emailProvider) throw new Error('Email provider not configured');

    let subject = template.subject;
    let htmlBody = template.htmlBody;
    let textBody = template.textBody;

    for (const [key, value] of Object.entries(data)) {
      const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
      subject = subject.replace(regex, String(value));
      htmlBody = htmlBody.replace(regex, String(value));
      textBody = textBody.replace(regex, String(value));
    }

    await this.emailProvider.send({ to, subject, html: htmlBody, text: textBody });
  }

  async sendPush(userId: string, payload: PushPayload): Promise<void> {
    if (!this.pushProvider) throw new Error('Push provider not configured');

    const tokens = await this.db.pushToken.findMany({ where: { userId } });
    for (const token of tokens) {
      await this.pushProvider.send(token.token, payload);
    }
  }

  async sendWebhook(webhookId: string, event: string, payload: Record<string, unknown>): Promise<void> {
    const webhook = await this.db.webhook.findUnique({ where: { id: webhookId } });
    if (!webhook || !webhook.active) return;

    const response = await fetch(webhook.url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-Webhook-Event': event, 'X-Webhook-Secret': webhook.secret },
      body: JSON.stringify({ event, payload, timestamp: new Date().toISOString() }),
    });

    if (!response.ok) {
      await this.db.webhook.update({ where: { id: webhookId }, data: { lastError: await response.text(), failureCount: { increment: 1 } } });
    }
  }

  private async sendEmailFromNotification(userId: string, title: string, body: string, data?: Record<string, unknown>): Promise<void> {
    const user = await this.db.user.findUnique({ where: { id: userId }, select: { email: true } });
    if (!user?.email) return;

    const template = await this.db.emailTemplate.findFirst({ where: { name: 'notification' } });
    if (template) {
      await this.sendEmail(user.email, template, { title, body, ...data });
    }
  }

  private async sendPushFromNotification(userId: string, payload: PushPayload): Promise<void> {
    try {
      await this.sendPush(userId, payload);
    } catch { /* push not critical */ }
  }

  private async sendWebhooks(userId: string, type: NotificationType, data?: Record<string, unknown>): Promise<void> {
    const webhooks = await this.db.webhook.findMany({ where: { userId, active: true, events: { has: type } } });
    for (const webhook of webhooks) {
      await this.sendWebhook(webhook.id, type, data ?? {});
    }
  }
}
