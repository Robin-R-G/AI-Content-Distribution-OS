import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
  Role,
  Permission,
  ResourceType,
  ActionType,
  CustomRole,
} from './types';

export class PermissionService {
  private supabase: SupabaseClient;

  constructor(supabaseUrl: string, supabaseServiceKey: string) {
    this.supabase = createClient(supabaseUrl, supabaseServiceKey);
  }

  async checkPermission(
    userId: string,
    resourceId: string,
    action: ActionType
  ): Promise<boolean> {
    const { data, error } = await this.supabase
      .from('role_assignments')
      .select(`
        roles (
          id,
          permissions
        )
      `)
      .eq('user_id', userId)
      .eq('resource_id', resourceId)
      .single();

    if (error || !data) return false;

    const role = data.roles as { permissions: Permission[] } | null;
    if (!role) return false;

    return role.permissions.some(
      (p) => p.actions.includes(action)
    );
  }

  async getRoles(orgId: string): Promise<Role[]> {
    const { data, error } = await this.supabase
      .from('roles')
      .select('*')
      .eq('organization_id', orgId)
      .order('created_at', { ascending: true });

    if (error) throw error;
    return (data ?? []).map(this.mapRole);
  }

  async createRole(orgId: string, role: CustomRole): Promise<Role> {
    const { data, error } = await this.supabase
      .from('roles')
      .insert({
        organization_id: orgId,
        name: role.name,
        description: role.description,
        is_system: false,
        permissions: role.permissions,
      })
      .select()
      .single();

    if (error) throw error;
    return this.mapRole(data);
  }

  async updateRole(roleId: string, permissions: Permission[]): Promise<Role> {
    const { data, error } = await this.supabase
      .from('roles')
      .update({
        permissions,
        updated_at: new Date().toISOString(),
      })
      .eq('id', roleId)
      .eq('is_system', false)
      .select()
      .single();

    if (error) throw error;
    return this.mapRole(data);
  }

  async deleteRole(roleId: string): Promise<void> {
    const { error } = await this.supabase
      .from('roles')
      .delete()
      .eq('id', roleId)
      .eq('is_system', false);

    if (error) throw error;
  }

  async assignRole(
    orgId: string,
    userId: string,
    roleId: string
  ): Promise<void> {
    const { error } = await this.supabase
      .from('role_assignments')
      .insert({
        user_id: userId,
        organization_id: orgId,
        role_id: roleId,
        assigned_at: new Date().toISOString(),
      });

    if (error) throw error;
  }

  async revokeRole(orgId: string, userId: string, roleId: string): Promise<void> {
    const { error } = await this.supabase
      .from('role_assignments')
      .delete()
      .eq('user_id', userId)
      .eq('organization_id', orgId)
      .eq('role_id', roleId);

    if (error) throw error;
  }

  getDefaultRoles(): CustomRole[] {
    return [
      {
        name: 'owner',
        description: 'Full access to all resources',
        permissions: [
          { resource: 'organization', actions: ['create', 'read', 'update', 'delete', 'manage'] },
          { resource: 'workspace', actions: ['create', 'read', 'update', 'delete', 'manage'] },
          { resource: 'content', actions: ['create', 'read', 'update', 'delete', 'publish', 'manage'] },
          { resource: 'member', actions: ['create', 'read', 'update', 'delete', 'manage'] },
          { resource: 'billing', actions: ['read', 'update', 'manage'] },
          { resource: 'settings', actions: ['read', 'update', 'manage'] },
          { resource: 'analytics', actions: ['read', 'manage'] },
          { resource: 'template', actions: ['create', 'read', 'update', 'delete', 'manage'] },
          { resource: 'integration', actions: ['create', 'read', 'update', 'delete', 'manage'] },
        ],
      },
      {
        name: 'admin',
        description: 'Manages workspaces, members, and content',
        permissions: [
          { resource: 'workspace', actions: ['create', 'read', 'update', 'delete'] },
          { resource: 'content', actions: ['create', 'read', 'update', 'delete', 'publish'] },
          { resource: 'member', actions: ['read', 'invite'] },
          { resource: 'settings', actions: ['read', 'update'] },
          { resource: 'analytics', actions: ['read'] },
          { resource: 'template', actions: ['create', 'read', 'update', 'delete'] },
          { resource: 'integration', actions: ['create', 'read', 'update', 'delete'] },
        ],
      },
      {
        name: 'editor',
        description: 'Creates and manages content',
        permissions: [
          { resource: 'workspace', actions: ['read'] },
          { resource: 'content', actions: ['create', 'read', 'update', 'publish'] },
          { resource: 'analytics', actions: ['read'] },
          { resource: 'template', actions: ['read', 'create', 'update'] },
        ],
      },
      {
        name: 'viewer',
        description: 'Read-only access',
        permissions: [
          { resource: 'workspace', actions: ['read'] },
          { resource: 'content', actions: ['read'] },
          { resource: 'analytics', actions: ['read'] },
          { resource: 'template', actions: ['read'] },
        ],
      },
    ];
  }

  async hasPermission(
    userId: string,
    resource: ResourceType,
    action: ActionType
  ): Promise<boolean> {
    const { data, error } = await this.supabase
      .from('role_assignments')
      .select(`
        roles (
          permissions
        )
      `)
      .eq('user_id', userId);

    if (error || !data) return false;

    return data.some((assignment) => {
      const role = assignment.roles as { permissions: Permission[] } | null;
      if (!role) return false;

      return role.permissions.some(
        (p) => p.resource === resource && p.actions.includes(action)
      );
    });
  }

  private mapRole(row: Record<string, unknown>): Role {
    return {
      id: row.id as string,
      organizationId: row.organization_id as string,
      name: row.name as string,
      description: row.description as string | undefined,
      isSystem: row.is_system as boolean,
      permissions: row.permissions as Permission[],
      createdAt: row.created_at as string,
      updatedAt: row.updated_at as string,
    };
  }
}
