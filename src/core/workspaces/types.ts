export interface Workspace {
  id: string;
  organizationId: string;
  name: string;
  description?: string;
  avatarUrl?: string;
  isArchived: boolean;
  createdAt: string;
  updatedAt: string;
  createdBy: string;
  settings?: WorkspaceSettings;
}

export interface WorkspaceMember {
  id: string;
  workspaceId: string;
  userId: string;
  role: 'admin' | 'editor' | 'viewer';
  addedAt: string;
  addedBy: string;
}

export interface WorkspaceSettings {
  defaultTimezone: string;
  defaultLanguage: string;
  autoPublish: boolean;
  approvalRequired: boolean;
  branding?: {
    logoUrl?: string;
    primaryColor?: string;
  };
  notifications?: {
    emailNotifications: boolean;
    slackNotifications: boolean;
    slackWebhookUrl?: string;
  };
}

export interface CreateWorkspaceRequest {
  organizationId: string;
  name: string;
  description?: string;
  createdBy: string;
  settings?: Partial<WorkspaceSettings>;
}

export interface UpdateWorkspaceRequest {
  name?: string;
  description?: string;
  avatarUrl?: string;
  settings?: Partial<WorkspaceSettings>;
}

export interface ConnectedAccount {
  id: string;
  workspaceId: string;
  platform: PlatformType;
  accountId: string;
  accountName: string;
  avatarUrl?: string;
  accessToken: string;
  refreshToken?: string;
  expiresAt?: string;
  scopes: string[];
  connectedAt: string;
  connectedBy: string;
  isActive: boolean;
  metadata?: Record<string, unknown>;
}

export type PlatformType =
  | 'twitter'
  | 'instagram'
  | 'facebook'
  | 'linkedin'
  | 'tiktok'
  | 'youtube'
  | 'pinterest'
  | 'threads'
  | 'mastodon';

export interface PlatformConnection {
  platform: PlatformType;
  accountId: string;
  accountName: string;
  accessToken: string;
  refreshToken?: string;
  expiresAt?: string;
  scopes: string[];
  metadata?: Record<string, unknown>;
}
