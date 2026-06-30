import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
  Workspace,
  WorkspaceMember,
  WorkspaceSettings,
  CreateWorkspaceRequest,
  UpdateWorkspaceRequest,
  ConnectedAccount,
  PlatformConnection,
  PlatformType,
} from './types';

export class WorkspaceService {
  private supabase: SupabaseClient;

  constructor(supabaseUrl: string, supabaseServiceKey: string) {
    this.supabase = createClient(supabaseUrl, supabaseServiceKey);
  }

  async create(orgId: string, name: string, createdBy: string): Promise<Workspace> {
    const request: CreateWorkspaceRequest = {
      organizationId: orgId,
      name,
      createdBy,
    };

    const { data, error } = await this.supabase
      .from('workspaces')
      .insert({
        organization_id: request.organizationId,
        name: request.name,
        created_by: request.createdBy,
        is_archived: false,
        settings: {
          defaultTimezone: 'UTC',
          defaultLanguage: 'en',
          autoPublish: false,
          approvalRequired: false,
        },
      })
      .select()
      .single();

    if (error) throw error;

    await this.supabase.from('workspace_members').insert({
      workspace_id: data.id,
      user_id: request.createdBy,
      role: 'admin',
      added_at: new Date().toISOString(),
      added_by: request.createdBy,
    });

    return this.mapWorkspace(data);
  }

  async getById(workspaceId: string): Promise<Workspace | null> {
    const { data, error } = await this.supabase
      .from('workspaces')
      .select('*')
      .eq('id', workspaceId)
      .single();

    if (error || !data) return null;
    return this.mapWorkspace(data);
  }

  async update(workspaceId: string, settings: Partial<UpdateWorkspaceRequest>): Promise<Workspace> {
    const updateData: Record<string, unknown> = {};

    if (settings.name) updateData.name = settings.name;
    if (settings.description !== undefined) updateData.description = settings.description;
    if (settings.avatarUrl) updateData.avatar_url = settings.avatarUrl;
    if (settings.settings) updateData.settings = settings.settings;
    updateData.updated_at = new Date().toISOString();

    const { data, error } = await this.supabase
      .from('workspaces')
      .update(updateData)
      .eq('id', workspaceId)
      .select()
      .single();

    if (error) throw error;
    return this.mapWorkspace(data);
  }

  async archive(workspaceId: string): Promise<Workspace> {
    const { data, error } = await this.supabase
      .from('workspaces')
      .update({
        is_archived: true,
        updated_at: new Date().toISOString(),
      })
      .eq('id', workspaceId)
      .select()
      .single();

    if (error) throw error;
    return this.mapWorkspace(data);
  }

  async list(orgId: string): Promise<Workspace[]> {
    const { data, error } = await this.supabase
      .from('workspaces')
      .select('*')
      .eq('organization_id', orgId)
      .eq('is_archived', false)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return (data ?? []).map(this.mapWorkspace);
  }

  async addMember(workspaceId: string, userId: string, role: 'admin' | 'editor' | 'viewer'): Promise<WorkspaceMember> {
    const { data, error } = await this.supabase
      .from('workspace_members')
      .upsert({
        workspace_id: workspaceId,
        user_id: userId,
        role,
        added_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) throw error;
    return this.mapMember(data);
  }

  async removeMember(workspaceId: string, userId: string): Promise<void> {
    const { error } = await this.supabase
      .from('workspace_members')
      .delete()
      .eq('workspace_id', workspaceId)
      .eq('user_id', userId);

    if (error) throw error;
  }

  async connectAccount(
    workspaceId: string,
    platform: PlatformType,
    credentials: PlatformConnection
  ): Promise<ConnectedAccount> {
    const { data, error } = await this.supabase
      .from('connected_accounts')
      .insert({
        workspace_id: workspaceId,
        platform,
        account_id: credentials.accountId,
        account_name: credentials.accountName,
        access_token: credentials.accessToken,
        refresh_token: credentials.refreshToken,
        expires_at: credentials.expiresAt,
        scopes: credentials.scopes,
        connected_at: new Date().toISOString(),
        is_active: true,
        metadata: credentials.metadata,
      })
      .select()
      .single();

    if (error) throw error;
    return this.mapConnectedAccount(data);
  }

  async disconnectAccount(workspaceId: string, accountId: string): Promise<void> {
    const { error } = await this.supabase
      .from('connected_accounts')
      .update({ is_active: false })
      .eq('workspace_id', workspaceId)
      .eq('id', accountId);

    if (error) throw error;
  }

  async getConnectedAccounts(workspaceId: string): Promise<ConnectedAccount[]> {
    const { data, error } = await this.supabase
      .from('connected_accounts')
      .select('*')
      .eq('workspace_id', workspaceId)
      .eq('is_active', true);

    if (error) throw error;
    return (data ?? []).map(this.mapConnectedAccount);
  }

  async switchWorkspace(workspaceId: string, userId: string): Promise<Workspace> {
    const workspace = await this.getById(workspaceId);
    if (!workspace) throw new Error('Workspace not found');

    const { data: member } = await this.supabase
      .from('workspace_members')
      .select('*')
      .eq('workspace_id', workspaceId)
      .eq('user_id', userId)
      .single();

    if (!member) throw new Error('User is not a member of this workspace');

    return workspace;
  }

  private mapWorkspace(row: Record<string, unknown>): Workspace {
    return {
      id: row.id as string,
      organizationId: row.organization_id as string,
      name: row.name as string,
      description: row.description as string | undefined,
      avatarUrl: row.avatar_url as string | undefined,
      isArchived: row.is_archived as boolean,
      createdAt: row.created_at as string,
      updatedAt: row.updated_at as string,
      createdBy: row.created_by as string,
      settings: row.settings as WorkspaceSettings | undefined,
    };
  }

  private mapMember(row: Record<string, unknown>): WorkspaceMember {
    return {
      id: row.id as string,
      workspaceId: row.workspace_id as string,
      userId: row.user_id as string,
      role: row.role as WorkspaceMember['role'],
      addedAt: row.added_at as string,
      addedBy: row.added_by as string,
    };
  }

  private mapConnectedAccount(row: Record<string, unknown>): ConnectedAccount {
    return {
      id: row.id as string,
      workspaceId: row.workspace_id as string,
      platform: row.platform as PlatformType,
      accountId: row.account_id as string,
      accountName: row.account_name as string,
      avatarUrl: row.avatar_url as string | undefined,
      accessToken: row.access_token as string,
      refreshToken: row.refresh_token as string | undefined,
      expiresAt: row.expires_at as string | undefined,
      scopes: row.scopes as string[],
      connectedAt: row.connected_at as string,
      connectedBy: row.connected_by as string,
      isActive: row.is_active as boolean,
      metadata: row.metadata as Record<string, unknown> | undefined,
    };
  }
}
