import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
  Organization,
  OrganizationMember,
  OrganizationInvitation,
  OrganizationSettings,
  CreateOrgRequest,
  UpdateOrgRequest,
  InviteMemberRequest,
} from './types';

export class OrganizationService {
  private supabase: SupabaseClient;

  constructor(supabaseUrl: string, supabaseServiceKey: string) {
    this.supabase = createClient(supabaseUrl, supabaseServiceKey);
  }

  async create(name: string, ownerId: string): Promise<Organization> {
    const slug = this.generateSlug(name);

    const { data: org, error: orgError } = await this.supabase
      .from('organizations')
      .insert({
        name,
        slug,
        owner_id: ownerId,
        plan: 'free',
        settings: {
          requireEmailVerification: true,
          enableSso: false,
        },
      })
      .select()
      .single();

    if (orgError) throw orgError;

    const { error: memberError } = await this.supabase
      .from('organization_members')
      .insert({
        organization_id: org.id,
        user_id: ownerId,
        role: 'owner',
        status: 'active',
        joined_at: new Date().toISOString(),
      });

    if (memberError) throw memberError;

    return this.mapOrganization(org);
  }

  async getById(orgId: string): Promise<Organization | null> {
    const { data, error } = await this.supabase
      .from('organizations')
      .select('*')
      .eq('id', orgId)
      .single();

    if (error || !data) return null;
    return this.mapOrganization(data);
  }

  async update(orgId: string, settings: Partial<UpdateOrgRequest>): Promise<Organization> {
    const updateData: Record<string, unknown> = {};

    if (settings.name) updateData.name = settings.name;
    if (settings.description) updateData.description = settings.description;
    if (settings.logoUrl) updateData.logo_url = settings.logoUrl;
    if (settings.settings) updateData.settings = settings.settings;
    updateData.updated_at = new Date().toISOString();

    const { data, error } = await this.supabase
      .from('organizations')
      .update(updateData)
      .eq('id', orgId)
      .select()
      .single();

    if (error) throw error;
    return this.mapOrganization(data);
  }

  async delete(orgId: string): Promise<void> {
    const { error } = await this.supabase
      .from('organizations')
      .delete()
      .eq('id', orgId);

    if (error) throw error;
  }

  async list(userId: string): Promise<Organization[]> {
    const { data, error } = await this.supabase
      .from('organization_members')
      .select('organization_id, organizations(*)')
      .eq('user_id', userId)
      .eq('status', 'active');

    if (error) throw error;

    return (data ?? []).map((row: Record<string, unknown>) =>
      this.mapOrganization(row.organizations as Record<string, unknown>)
    );
  }

  async addMember(orgId: string, userId: string, role: string): Promise<OrganizationMember> {
    const { data, error } = await this.supabase
      .from('organization_members')
      .insert({
        organization_id: orgId,
        user_id: userId,
        role,
        status: 'active',
        joined_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;
    return this.mapMember(data);
  }

  async removeMember(orgId: string, userId: string): Promise<void> {
    const { error } = await this.supabase
      .from('organization_members')
      .delete()
      .eq('organization_id', orgId)
      .eq('user_id', userId);

    if (error) throw error;
  }

  async updateMemberRole(orgId: string, userId: string, role: string): Promise<OrganizationMember> {
    const { data, error } = await this.supabase
      .from('organization_members')
      .update({ role, updated_at: new Date().toISOString() })
      .eq('organization_id', orgId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return this.mapMember(data);
  }

  async invite(
    orgId: string,
    email: string,
    role: string,
    invitedBy: string
  ): Promise<OrganizationInvitation> {
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

    const { data, error } = await this.supabase
      .from('organization_invitations')
      .insert({
        organization_id: orgId,
        email,
        role,
        invited_by: invitedBy,
        status: 'pending',
        expires_at: expiresAt,
        created_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;
    return this.mapInvitation(data);
  }

  async acceptInvite(inviteId: string, userId: string): Promise<OrganizationMember> {
    const { data: invite, error: inviteError } = await this.supabase
      .from('organization_invitations')
      .select('*')
      .eq('id', inviteId)
      .eq('status', 'pending')
      .single();

    if (inviteError || !invite) throw new Error('Invalid or expired invitation');

    const now = new Date().toISOString();
    const expiresAt = new Date(invite.expires_at);
    if (expiresAt < new Date()) {
      await this.supabase
        .from('organization_invitations')
        .update({ status: 'expired' })
        .eq('id', inviteId);
      throw new Error('Invitation has expired');
    }

    const member = await this.addMember(
      invite.organization_id,
      userId,
      invite.role
    );

    await this.supabase
      .from('organization_invitations')
      .update({ status: 'accepted' })
      .eq('id', inviteId);

    return member;
  }

  async getMembers(orgId: string): Promise<OrganizationMember[]> {
    const { data, error } = await this.supabase
      .from('organization_members')
      .select('*')
      .eq('organization_id', orgId)
      .eq('status', 'active');

    if (error) throw error;
    return (data ?? []).map(this.mapMember);
  }

  async getSettings(orgId: string): Promise<OrganizationSettings | null> {
    const { data, error } = await this.supabase
      .from('organizations')
      .select('settings')
      .eq('id', orgId)
      .single();

    if (error || !data) return null;
    return (data.settings as OrganizationSettings) ?? null;
  }

  async updateSettings(
    orgId: string,
    settings: Partial<OrganizationSettings>
  ): Promise<OrganizationSettings> {
    const { data: existing } = await this.supabase
      .from('organizations')
      .select('settings')
      .eq('id', orgId)
      .single();

    const merged = {
      ...((existing?.settings as OrganizationSettings) ?? {}),
      ...settings,
    };

    const { data, error } = await this.supabase
      .from('organizations')
      .update({ settings: merged, updated_at: new Date().toISOString() })
      .eq('id', orgId)
      .select('settings')
      .single();

    if (error) throw error;
    return (data.settings as OrganizationSettings) ?? merged;
  }

  private generateSlug(name: string): string {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '')
      .slice(0, 63);
  }

  private mapOrganization(row: Record<string, unknown>): Organization {
    return {
      id: row.id as string,
      name: row.name as string,
      slug: row.slug as string,
      ownerId: row.owner_id as string,
      logoUrl: row.logo_url as string | undefined,
      description: row.description as string | undefined,
      plan: row.plan as Organization['plan'],
      createdAt: row.created_at as string,
      updatedAt: row.updated_at as string,
      settings: row.settings as OrganizationSettings | undefined,
      billing: row.billing as BillingInfo | undefined,
    };
  }

  private mapMember(row: Record<string, unknown>): OrganizationMember {
    return {
      id: row.id as string,
      organizationId: row.organization_id as string,
      userId: row.user_id as string,
      role: row.role as string,
      joinedAt: row.joined_at as string,
      invitedBy: row.invited_by as string | undefined,
      status: row.status as OrganizationMember['status'],
    };
  }

  private mapInvitation(row: Record<string, unknown>): OrganizationInvitation {
    return {
      id: row.id as string,
      organizationId: row.organization_id as string,
      email: row.email as string,
      role: row.role as string,
      invitedBy: row.invited_by as string,
      status: row.status as OrganizationInvitation['status'],
      expiresAt: row.expires_at as string,
      createdAt: row.created_at as string,
    };
  }
}

interface BillingInfo {
  plan: string;
  status: string;
  currentPeriodStart?: string;
  currentPeriodEnd?: string;
  cancelAt?: string;
  stripeCustomerId?: string;
  stripeSubscriptionId?: string;
}
