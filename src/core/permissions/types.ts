export type ResourceType =
  | 'organization'
  | 'workspace'
  | 'content'
  | 'member'
  | 'billing'
  | 'settings'
  | 'analytics'
  | 'template'
  | 'integration';

export type ActionType = 'create' | 'read' | 'update' | 'delete' | 'publish' | 'manage';

export interface Role {
  id: string;
  organizationId: string;
  name: string;
  description?: string;
  isSystem: boolean;
  permissions: Permission[];
  createdAt: string;
  updatedAt: string;
}

export interface Permission {
  resource: ResourceType;
  actions: ActionType[];
}

export interface PermissionMatrix {
  [roleName: string]: {
    [resource in ResourceType]?: ActionType[];
  };
}

export interface CustomRole {
  name: string;
  description?: string;
  permissions: Permission[];
}

export interface RoleAssignment {
  id: string;
  userId: string;
  organizationId: string;
  roleId: string;
  workspaceId?: string;
  assignedBy: string;
  assignedAt: string;
  expiresAt?: string;
}
