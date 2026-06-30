export type ContentType = 'post' | 'story' | 'reel' | 'thread' | 'article';

export type ContentStatus = 'draft' | 'scheduled' | 'published' | 'archived';

export interface Content {
  id: string;
  workspaceId: string;
  title?: string;
  body: string;
  type: ContentType;
  status: ContentStatus;
  mediaUrls: string[];
  tags: string[];
  metadata?: ContentMetadata;
  seo?: SEOMetadata;
  scheduledAt?: string;
  publishedAt?: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  version: number;
}

export interface ContentVersion {
  id: string;
  contentId: string;
  version: number;
  body: string;
  title?: string;
  metadata?: ContentMetadata;
  createdBy: string;
  createdAt: string;
  changeNote?: string;
}

export interface ContentTemplate {
  id: string;
  workspaceId: string;
  name: string;
  description?: string;
  type: ContentType;
  body: string;
  title?: string;
  variables: TemplateVariable[];
  tags: string[];
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface TemplateVariable {
  name: string;
  type: 'text' | 'number' | 'date' | 'image' | 'select';
  label: string;
  defaultValue?: string;
  options?: string[];
  required: boolean;
}

export interface ContentMetadata {
  platforms?: string[];
  targetAudience?: string;
  campaignId?: string;
  category?: string;
  language?: string;
  location?: string;
  customFields?: Record<string, unknown>;
}

export interface SEOMetadata {
  metaTitle?: string;
  metaDescription?: string;
  focusKeyword?: string;
  canonicalUrl?: string;
  ogImage?: string;
  noIndex?: boolean;
}
