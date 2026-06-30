# Backend Architecture

## Supabase Setup

### Project Structure

```
supabase/
├── migrations/           # Database migrations
│   ├── 001_initial.sql
│   ├── 002_add_content_types.sql
│   └── ...
├── functions/            # Edge Functions
│   ├── auth/
│   │   ├── register.ts
│   │   ├── login.ts
│   │   └── refresh.ts
│   ├── content/
│   │   ├── create.ts
│   │   ├── list.ts
│   │   └── update.ts
│   ├── ai/
│   │   └── generate.ts
│   ├── publishing/
│   │   ├── schedule.ts
│   │   └── webhook.ts
│   └── webhook/
│       └── stripe.ts
├── seed.sql              # Seed data
├── config.toml           # Supabase configuration
└── types.ts              # Auto-generated types
```

### Supabase Client Configuration

```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

// Service role client (admin operations)
export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// User client (authenticated operations)
export function createUserClient(accessToken: string) {
  return createClient(supabaseUrl, process.env.SUPABASE_ANON_KEY!, {
    global: {
      headers: { Authorization: `Bearer ${accessToken}` }
    }
  });
}
```

## Edge Functions Structure

### Function Template

```typescript
// supabase/functions/content/create.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    const authHeader = req.headers.get('Authorization')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // Get user
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError) throw authError;

    // Parse request
    const { title, body, type, workspace_id, metadata } = await req.json();

    // Create content
    const { data, error } = await supabase
      .from('contents')
      .insert({
        user_id: user.id,
        workspace_id,
        title,
        body,
        type,
        metadata,
        status: 'draft'
      })
      .select()
      .single();

    if (error) throw error;

    return new Response(
      JSON.stringify({ data }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
```

### Function Organization

```
functions/
├── _shared/
│   ├── auth.ts           # Auth utilities
│   ├── cors.ts           # CORS headers
│   ├── errors.ts         # Error handling
│   ├── logger.ts         # Structured logging
│   └── supabase.ts       # Client setup
├── auth/
│   ├── register.ts       # User registration
│   ├── login.ts          # User login
│   ├── logout.ts         # User logout
│   ├── refresh.ts        # Token refresh
│   ├── mfa.ts            # MFA operations
│   └── oauth.ts          # OAuth callback
├── content/
│   ├── create.ts         # Create content
│   ├── list.ts           # List contents
│   ├── get.ts            # Get single content
│   ├── update.ts         # Update content
│   ├── delete.ts         # Delete content
│   └── versions.ts       # Version management
├── ai/
│   ├── generate.ts       # Generate content
│   ├── prompts.ts        # Prompt management
│   └── usage.ts          # Usage tracking
├── publishing/
│   ├── schedule.ts       # Schedule posts
│   ├── publish.ts        # Publish now
│   ├── cancel.ts         # Cancel scheduled
│   └── webhook.ts        # Platform webhooks
├── analytics/
│   ├── dashboard.ts      # Dashboard data
│   ├── posts.ts          # Post analytics
│   └── export.ts         # Export data
├── billing/
│   ├── subscription.ts   # Subscription management
│   ├── invoice.ts        # Invoice operations
│   └── usage.ts          # Usage metering
└── webhooks/
    ├── stripe.ts         # Stripe webhooks
    ├── social.ts         # Social platform webhooks
    └── internal.ts       # Internal webhooks
```

## Database Migrations Strategy

### Migration Tool

Using Supabase CLI for migrations:

```bash
# Create new migration
supabase migration new add_content_types

# Apply migrations locally
supabase db reset

# Push to remote
supabase db push

# Generate types
supabase gen types typescript --local > types.ts
```

### Migration Naming Convention

```
YYYYMMDDHHMMSS_description.sql
20260101120000_create_users_table.sql
20260102120000_add_content_types.sql
20260103120000_create_analytics_tables.sql
```

### Migration Template

```sql
-- Migration: YYYYMMDDHHMMSS_description
-- Description: Brief description of changes

BEGIN;

-- Up migration
CREATE TABLE IF NOT EXISTS public.contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  workspace_id UUID NOT NULL REFERENCES public.workspaces(id),
  title TEXT,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'post',
  status TEXT NOT NULL DEFAULT 'draft',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_contents_user_id ON public.contents(user_id);
CREATE INDEX idx_contents_workspace_id ON public.contents(workspace_id);
CREATE INDEX idx_contents_status ON public.contents(status);

-- Add RLS policies
ALTER TABLE public.contents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own contents"
  ON public.contents FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own contents"
  ON public.contents FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own contents"
  ON public.contents FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete own contents"
  ON public.contents FOR DELETE
  USING (user_id = auth.uid());

-- Add triggers
CREATE TRIGGER handle_updated_at
  BEFORE UPDATE ON public.contents
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

COMMIT;
```

### Migration Safety

| Check | Description |
|-------|-------------|
| Reversibility | Every migration has a down migration |
| Data Loss | No destructive changes without backup |
| Locking | Avoid table locks on large tables |
| Idempotency | Migrations can be run multiple times |
| Testing | Migrations tested on staging first |

## Real-time Subscriptions

### Client Subscription

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Subscribe to content changes
const subscription = supabase
  .channel('contents')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'contents',
      filter: `workspace_id=eq.${workspaceId}`
    },
    (payload) => {
      console.log('Content changed:', payload);
      // Update local state
    }
  )
  .subscribe();

// Cleanup
supabase.removeChannel(subscription);
```

### Real-time Events

```typescript
interface RealtimeEvent {
  eventType: 'INSERT' | 'UPDATE' | 'DELETE';
  new: Record<string, any>;
  old: Record<string, any>;
  table: string;
  schema: string;
}

// Example: Real-time notifications
supabase
  .channel('notifications')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'notifications',
      filter: `user_id=eq.${userId}`
    },
    (payload) => {
      showNotification(payload.new);
    }
  )
  .subscribe();
```

### Real-time Performance

| Configuration | Value | Description |
|--------------|-------|-------------|
| Max Payload | 1MB | Maximum event payload size |
| Heartbeat | 30s | Connection keepalive interval |
| Reconnect | 2s | Reconnection attempt delay |
| Max Retries | 5 | Maximum reconnection attempts |

## Row Level Security Policies

### Policy Organization

```sql
-- User policies (own data only)
CREATE POLICY "users_select_own"
  ON public.users FOR SELECT
  USING (id = auth.uid());

-- Organization policies (members only)
CREATE POLICY "orgs_select_members"
  ON public.organizations FOR SELECT
  USING (
    id IN (
      SELECT organization_id
      FROM public.organization_members
      WHERE user_id = auth.uid()
    )
  );

-- Workspace policies (org members)
CREATE POLICY "workspaces_select_org_members"
  ON public.workspaces FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id
      FROM public.organization_members
      WHERE user_id = auth.uid()
    )
  );

-- Content policies (workspace members)
CREATE POLICY "contents_select_workspace_members"
  ON public.contents FOR SELECT
  USING (
    workspace_id IN (
      SELECT w.id
      FROM public.workspaces w
      JOIN public.organization_members om
        ON w.organization_id = om.organization_id
      WHERE om.user_id = auth.uid()
    )
  );
```

### Policy Templates

```sql
-- Read policy
CREATE POLICY "{table}_select_{scope}"
  ON public.{table} FOR SELECT
  USING ({condition});

-- Insert policy
CREATE POLICY "{table}_insert_{scope}"
  ON public.{table} FOR INSERT
  WITH CHECK ({condition});

-- Update policy
CREATE POLICY "{table}_update_{scope}"
  ON public.{table} FOR UPDATE
  USING ({condition})
  WITH CHECK ({condition});

-- Delete policy
CREATE POLICY "{table}_delete_{scope}"
  ON public.{table} FOR DELETE
  USING ({condition});
```

### Performance Considerations

| Practice | Description |
|----------|-------------|
| Indexes | Add indexes on columns used in policy conditions |
| Simplicity | Keep policies as simple as possible |
| Caching | Use `auth.uid()` function results |
| Testing | Test policies with different user roles |
