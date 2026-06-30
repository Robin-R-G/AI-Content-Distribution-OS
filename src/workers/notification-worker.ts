import { Worker, Job } from 'bullmq';

interface NotificationJobData {
  userId: string;
  type: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  channels: string[];
}

export function createNotificationWorker(redis: any, db: any, emailProvider?: any, pushProvider?: any) {
  const worker = new Worker(
    'notifications',
    async (job: Job<NotificationJobData>) => {
      const { userId, type, title, body, data, channels } = job.data;

      const notification = await db.notification.create({
        data: {
          userId, type, title, body, data, read: false, channel: 'in_app', createdAt: new Date(),
        },
      });

      const results: Record<string, boolean> = {};

      for (const channel of channels) {
        try {
          switch (channel) {
            case 'email': {
              if (!emailProvider) { results.email = false; break; }
              const user = await db.user.findUnique({ where: { id: userId }, select: { email: true, firstName: true } });
              if (!user?.email) { results.email = false; break; }

              const template = await db.emailTemplate.findFirst({ where: { name: 'notification' } });
              if (!template) { results.email = false; break; }

              let html = template.htmlBody.replace(/\{\{title\}\}/g, title).replace(/\{\{body\}\}/g, body);
              if (user.firstName) html = html.replace(/\{\{firstName\}\}/g, user.firstName);

              await emailProvider.send({ to: user.email, subject: title, html });
              results.email = true;
              break;
            }

            case 'push': {
              if (!pushProvider) { results.push = false; break; }
              const tokens = await db.pushToken.findMany({ where: { userId, active: true } });
              for (const token of tokens) {
                await pushProvider.send(token.token, { title, body, data, badge: 1, tag: type });
              }
              results.push = true;
              break;
            }

            case 'webhook': {
              const webhooks = await db.webhook.findMany({ where: { userId, active: true } });
              for (const webhook of webhooks) {
                await fetch(webhook.url, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json', 'X-Webhook-Secret': webhook.secret },
                  body: JSON.stringify({ event: type, notification: { title, body, data }, timestamp: new Date().toISOString() }),
                });
              }
              results.webhook = true;
              break;
            }

            default:
              results[channel] = false;
          }
        } catch (error: any) {
          console.error(`Notification ${channel} failed for user ${userId}:`, error.message);
          results[channel] = false;
        }
      }

      return { notificationId: notification.id, results };
    },
    {
      connection: redis,
      concurrency: 10,
      limiter: { max: 50, duration: 60000 },
    }
  );

  worker.on('failed', (job, error) => {
    console.error(`Notification job ${job?.id} failed:`, error.message);
  });

  return worker;
}
