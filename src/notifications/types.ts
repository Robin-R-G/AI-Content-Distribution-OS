export type NotificationType =
  | 'publish_success'
  | 'publish_failed'
  | 'schedule_reminder'
  | 'comment_alert'
  | 'mention_alert'
  | 'follower_milestone'
  | 'analytics_insight'
  | 'ai_job_complete'
  | 'billing_alert'
  | 'team_mention'
  | 'system_alert'
  | 'weekly_report';

export type NotificationChannel = 'in_app' | 'email' | 'push' | 'webhook' | 'sms';

export interface Notification {
  id: string;
  userId: string;
  workspaceId?: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  read: boolean;
  channel: NotificationChannel;
  createdAt: Date;
  readAt?: Date;
}

export interface NotificationPreference {
  userId: string;
  channel: NotificationChannel;
  type: NotificationType;
  enabled: boolean;
  frequency?: 'immediate' | 'daily_digest' | 'weekly_digest';
}

export interface EmailTemplate {
  id: string;
  name: string;
  subject: string;
  htmlBody: string;
  textBody: string;
  variables: string[];
}

export interface PushPayload {
  title: string;
  body: string;
  icon?: string;
  image?: string;
  url?: string;
  data?: Record<string, unknown>;
  badge?: number;
  tag?: string;
}
