export interface Organization {
  id: string;
  name: string;
  slug: string;
  ownerId: string;
  logoUrl?: string;
  description?: string;
  plan: 'free' | 'starter' | 'pro' | 'enterprise';
  createdAt: string;
  updatedAt: string;
  settings?: OrganizationSettings;
  billing?: BillingInfo;
}

export interface OrganizationMember {
  id: string;
  organizationId: string;
  userId: string;
  role: string;
  joinedAt: string;
  invitedBy?: string;
  status: 'active' | 'invited' | 'suspended';
}

export interface OrganizationInvitation {
  id: string;
  organizationId: string;
  email: string;
  role: string;
  invitedBy: string;
  status: 'pending' | 'accepted' | 'expired';
  expiresAt: string;
  createdAt: string;
}

export interface OrganizationSettings {
  defaultWorkspaceId?: string;
  allowedDomains?: string[];
  requireEmailVerification: boolean;
  enableSso: boolean;
  ssoConfig?: SSOConfig;
  branding?: {
    logoUrl?: string;
    primaryColor?: string;
    companyName?: string;
  };
  security?: {
    sessionTimeout: number;
    ipWhitelist?: string[];
    enforceMfa: boolean;
  };
}

export interface BillingInfo {
  plan: string;
  status: 'active' | 'past_due' | 'canceled' | 'trialing';
  currentPeriodStart?: string;
  currentPeriodEnd?: string;
  cancelAt?: string;
  stripeCustomerId?: string;
  stripeSubscriptionId?: string;
}

export interface SSOConfig {
  enabled: boolean;
  provider?: 'okta' | 'auth0' | 'azure_ad' | 'google_workspace';
  entityId?: string;
  ssoUrl?: string;
  certificate?: string;
  metadataUrl?: string;
}

export interface CreateOrgRequest {
  name: string;
  ownerId: string;
  description?: string;
  settings?: Partial<OrganizationSettings>;
}

export interface UpdateOrgRequest {
  name?: string;
  description?: string;
  logoUrl?: string;
  settings?: Partial<OrganizationSettings>;
}

export interface InviteMemberRequest {
  organizationId: string;
  email: string;
  role: string;
  invitedBy: string;
}
