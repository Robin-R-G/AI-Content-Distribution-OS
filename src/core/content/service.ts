import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
  Content,
  ContentVersion,
  ContentTemplate,
  ContentType,
  ContentStatus,
  ContentMetadata,
  SEOMetadata,
} from './types';

export class ContentService {
  private supabase: SupabaseClient;

  constructor(supabaseUrl: string, supabaseServiceKey: string) {
    this.supabase = createClient(supabaseUrl, supabaseServiceKey);
  }

  async create(
    workspaceId: string,
    content: {
      title?: string;
      body: string;
      type: ContentType;
      mediaUrls?: string[];
      tags?: string[];
      metadata?: ContentMetadata;
      seo?: SEOMetadata;
      scheduledAt?: string;
      createdBy: string;
    }
  ): Promise<Content> {
    const now = new Date().toISOString();

    const { data, error } = await this.supabase
      .from('content')
      .insert({
        workspace_id: workspaceId,
        title: content.title,
        body: content.body,
        type: content.type,
        status: content.scheduledAt ? 'scheduled' : 'draft',
        media_urls: content.mediaUrls ?? [],
        tags: content.tags ?? [],
        metadata: content.metadata,
        seo: content.seo,
        scheduled_at: content.scheduledAt,
        created_by: content.createdBy,
        version: 1,
      })
      .select()
      .single();

    if (error) throw error;

    await this.supabase.from('content_versions').insert({
      content_id: data.id,
      version: 1,
      body: content.body,
      title: content.title,
      metadata: content.metadata,
      created_by: content.createdBy,
      created_at: now,
    });

    return this.mapContent(data);
  }

  async getById(contentId: string): Promise<Content | null> {
    const { data, error } = await this.supabase
      .from('content')
      .select('*')
      .eq('id', contentId)
      .single();

    if (error || !data) return null;
    return this.mapContent(data);
  }

  async update(
    contentId: string,
    updates: {
      title?: string;
      body?: string;
      status?: ContentStatus;
      mediaUrls?: string[];
      tags?: string[];
      metadata?: ContentMetadata;
      seo?: SEOMetadata;
      scheduledAt?: string;
      changeNote?: string;
      updatedBy: string;
    }
  ): Promise<Content> {
    const existing = await this.getById(contentId);
    if (!existing) throw new Error('Content not found');

    const updateData: Record<string, unknown> = {};
    if (updates.title !== undefined) updateData.title = updates.title;
    if (updates.body !== undefined) updateData.body = updates.body;
    if (updates.status !== undefined) updateData.status = updates.status;
    if (updates.mediaUrls !== undefined) updateData.media_urls = updates.mediaUrls;
    if (updates.tags !== undefined) updateData.tags = updates.tags;
    if (updates.metadata !== undefined) updateData.metadata = updates.metadata;
    if (updates.seo !== undefined) updateData.seo = updates.seo;
    if (updates.scheduledAt !== undefined) updateData.scheduled_at = updates.scheduledAt;
    updateData.version = existing.version + 1;
    updateData.updated_at = new Date().toISOString();

    if (updates.status === 'published') {
      updateData.published_at = new Date().toISOString();
    }

    const { data, error } = await this.supabase
      .from('content')
      .update(updateData)
      .eq('id', contentId)
      .select()
      .single();

    if (error) throw error;

    const newVersion = existing.version + 1;
    await this.supabase.from('content_versions').insert({
      content_id: contentId,
      version: newVersion,
      body: updates.body ?? existing.body,
      title: updates.title ?? existing.title,
      metadata: updates.metadata ?? existing.metadata,
      created_by: updates.updatedBy,
      created_at: new Date().toISOString(),
      change_note: updates.changeNote,
    });

    return this.mapContent(data);
  }

  async delete(contentId: string): Promise<void> {
    const { error } = await this.supabase
      .from('content')
      .delete()
      .eq('id', contentId);

    if (error) throw error;
  }

  async list(
    workspaceId: string,
    filters?: {
      type?: ContentType;
      status?: ContentStatus;
      tags?: string[];
      search?: string;
      limit?: number;
      offset?: number;
    }
  ): Promise<Content[]> {
    let query = this.supabase
      .from('content')
      .select('*')
      .eq('workspace_id', workspaceId)
      .order('updated_at', { ascending: false });

    if (filters?.type) query = query.eq('type', filters.type);
    if (filters?.status) query = query.eq('status', filters.status);
    if (filters?.tags && filters.tags.length > 0) {
      query = query.overlaps('tags', filters.tags);
    }
    if (filters?.search) {
      query = query.or(`title.ilike.%${filters.search}%,body.ilike.%${filters.search}%`);
    }
    if (filters?.limit) query = query.limit(filters.limit);
    if (filters?.offset) query = query.range(filters.offset, (filters.offset + (filters.limit ?? 20)) - 1);

    const { data, error } = await query;

    if (error) throw error;
    return (data ?? []).map(this.mapContent);
  }

  async duplicate(contentId: string, createdBy: string): Promise<Content> {
    const original = await this.getById(contentId);
    if (!original) throw new Error('Content not found');

    return this.create(original.workspaceId, {
      title: `${original.title ?? 'Untitled'} (Copy)`,
      body: original.body,
      type: original.type,
      mediaUrls: [...original.mediaUrls],
      tags: [...original.tags],
      metadata: original.metadata ? { ...original.metadata } : undefined,
      seo: original.seo ? { ...original.seo } : undefined,
      createdBy,
    });
  }

  async archive(contentId: string): Promise<Content> {
    const { data, error } = await this.supabase
      .from('content')
      .update({
        status: 'archived',
        updated_at: new Date().toISOString(),
      })
      .eq('id', contentId)
      .select()
      .single();

    if (error) throw error;
    return this.mapContent(data);
  }

  async getVersion(contentId: string, version: number): Promise<ContentVersion | null> {
    const { data, error } = await this.supabase
      .from('content_versions')
      .select('*')
      .eq('content_id', contentId)
      .eq('version', version)
      .single();

    if (error || !data) return null;
    return this.mapVersion(data);
  }

  async getVersions(contentId: string): Promise<ContentVersion[]> {
    const { data, error } = await this.supabase
      .from('content_versions')
      .select('*')
      .eq('content_id', contentId)
      .order('version', { ascending: false });

    if (error) throw error;
    return (data ?? []).map(this.mapVersion);
  }

  async restoreVersion(contentId: string, version: number): Promise<Content> {
    const versionData = await this.getVersion(contentId, version);
    if (!versionData) throw new Error('Version not found');

    const existing = await this.getById(contentId);
    if (!existing) throw new Error('Content not found');

    return this.update(contentId, {
      title: versionData.title ?? existing.title,
      body: versionData.body,
      metadata: versionData.metadata as ContentMetadata | undefined,
      changeNote: `Restored from version ${version}`,
      updatedBy: versionData.createdBy,
    });
  }

  async createTemplate(
    workspaceId: string,
    template: {
      name: string;
      description?: string;
      type: ContentType;
      body: string;
      title?: string;
      variables?: ContentTemplate['variables'];
      tags?: string[];
      createdBy: string;
    }
  ): Promise<ContentTemplate> {
    const { data, error } = await this.supabase
      .from('content_templates')
      .insert({
        workspace_id: workspaceId,
        name: template.name,
        description: template.description,
        type: template.type,
        body: template.body,
        title: template.title,
        variables: template.variables ?? [],
        tags: template.tags ?? [],
        created_by: template.createdBy,
      })
      .select()
      .single();

    if (error) throw error;
    return this.mapTemplate(data);
  }

  async getTemplates(workspaceId: string): Promise<ContentTemplate[]> {
    const { data, error } = await this.supabase
      .from('content_templates')
      .select('*')
      .eq('workspace_id', workspaceId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return (data ?? []).map(this.mapTemplate);
  }

  private mapContent(row: Record<string, unknown>): Content {
    return {
      id: row.id as string,
      workspaceId: row.workspace_id as string,
      title: row.title as string | undefined,
      body: row.body as string,
      type: row.type as ContentType,
      status: row.status as ContentStatus,
      mediaUrls: (row.media_urls as string[]) ?? [],
      tags: (row.tags as string[]) ?? [],
      metadata: row.metadata as ContentMetadata | undefined,
      seo: row.seo as SEOMetadata | undefined,
      scheduledAt: row.scheduled_at as string | undefined,
      publishedAt: row.published_at as string | undefined,
      createdBy: row.created_by as string,
      createdAt: row.created_at as string,
      updatedAt: row.updated_at as string,
      version: row.version as number,
    };
  }

  private mapVersion(row: Record<string, unknown>): ContentVersion {
    return {
      id: row.id as string,
      contentId: row.content_id as string,
      version: row.version as number,
      body: row.body as string,
      title: row.title as string | undefined,
      metadata: row.metadata as ContentMetadata | undefined,
      createdBy: row.created_by as string,
      createdAt: row.created_at as string,
      changeNote: row.change_note as string | undefined,
    };
  }

  private mapTemplate(row: Record<string, unknown>): ContentTemplate {
    return {
      id: row.id as string,
      workspaceId: row.workspace_id as string,
      name: row.name as string,
      description: row.description as string | undefined,
      type: row.type as ContentType,
      body: row.body as string,
      title: row.title as string | undefined,
      variables: (row.variables as ContentTemplate['variables']) ?? [],
      tags: (row.tags as string[]) ?? [],
      createdBy: row.created_by as string,
      createdAt: row.created_at as string,
      updatedAt: row.updated_at as string,
    };
  }
}
