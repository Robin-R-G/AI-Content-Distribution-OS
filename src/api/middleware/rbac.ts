import { Request, Response, NextFunction } from 'express';

type Role = 'owner' | 'admin' | 'editor' | 'viewer' | 'api_key';

interface Permission {
  resource: string;
  actions: string[];
}

const ROLE_HIERARCHY: Record<Role, number> = {
  owner: 5,
  admin: 4,
  editor: 3,
  viewer: 2,
  api_key: 1,
};

const ROLE_PERMISSIONS: Record<Role, Permission[]> = {
  owner: [
    { resource: '*', actions: ['*'] },
  ],
  admin: [
    { resource: 'workspace', actions: ['read', 'update', 'delete'] },
    { resource: 'accounts', actions: ['create', 'read', 'update', 'delete'] },
    { resource: 'posts', actions: ['create', 'read', 'update', 'delete', 'publish'] },
    { resource: 'analytics', actions: ['read', 'export'] },
    { resource: 'team', actions: ['invite', 'remove', 'update_role'] },
    { resource: 'billing', actions: ['read', 'update'] },
    { resource: 'settings', actions: ['read', 'update'] },
  ],
  editor: [
    { resource: 'workspace', actions: ['read'] },
    { resource: 'accounts', actions: ['read'] },
    { resource: 'posts', actions: ['create', 'read', 'update', 'publish'] },
    { resource: 'analytics', actions: ['read'] },
    { resource: 'ai', actions: ['use'] },
  ],
  viewer: [
    { resource: 'workspace', actions: ['read'] },
    { resource: 'accounts', actions: ['read'] },
    { resource: 'posts', actions: ['read'] },
    { resource: 'analytics', actions: ['read'] },
  ],
  api_key: [
    { resource: 'posts', actions: ['create', 'read', 'update'] },
    { resource: 'analytics', actions: ['read'] },
    { resource: 'ai', actions: ['use'] },
  ],
};

export function requireRole(minRole: Role) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user) return res.status(401).json({ error: 'Authentication required' });

    const userLevel = ROLE_HIERARCHY[user.role as Role] ?? 0;
    const requiredLevel = ROLE_HIERARCHY[minRole];

    if (userLevel < requiredLevel) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
}

export function requirePermission(resource: string, action: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user) return res.status(401).json({ error: 'Authentication required' });

    const role = user.role as Role;
    const permissions = ROLE_PERMISSIONS[role] ?? [];

    const hasWildcard = permissions.some((p) => p.resource === '*' && p.actions.includes('*'));
    if (hasWildcard) return next();

    const hasPermission = permissions.some(
      (p) => (p.resource === resource || p.resource === '*') && (p.actions.includes(action) || p.actions.includes('*'))
    );

    if (!hasPermission) {
      return res.status(403).json({ error: `Missing permission: ${resource}:${action}` });
    }

    next();
  };
}

export function requireOwnership(getOwnerId: (req: Request) => Promise<string>) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user) return res.status(401).json({ error: 'Authentication required' });

    const role = user.role as Role;
    if (role === 'owner' || role === 'admin') return next();

    try {
      const ownerId = await getOwnerId(req);
      if (ownerId !== user.userId) {
        return res.status(403).json({ error: 'Access denied' });
      }
    } catch {
      return res.status(404).json({ error: 'Resource not found' });
    }

    next();
  };
}

export function rbacMiddleware(db: any) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user;
    if (!user) return next();

    const membership = await db.workspaceMember.findFirst({
      where: { workspaceId: req.params.workspaceId, userId: user.userId },
    });

    if (membership) {
      (req as any).user.role = membership.role;
    }

    next();
  };
}
