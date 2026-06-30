export interface PluginMetadata {
  id: string;
  name: string;
  version: string;
  author: string;
  description: string;
  category: PluginCategory;
  icon?: string;
  permissions: string[];
  configSchema?: Record<string, PluginConfigField>;
}

export type PluginCategory =
  | 'social'
  | 'storage'
  | 'ai'
  | 'design'
  | 'analytics'
  | 'notification'
  | 'payment'
  | 'video'
  | 'cms';

export interface PluginConfigField {
  type: 'string' | 'number' | 'boolean' | 'select' | 'secret';
  label: string;
  description?: string;
  required: boolean;
  default?: unknown;
  options?: string[];
}

export interface PluginContext {
  orgId: string;
  workspaceId: string;
  userId: string;
  config: Record<string, unknown>;
  logger: PluginLogger;
  storage: PluginStorage;
  http: PluginHttpClient;
}

export interface PluginLogger {
  info(message: string, data?: Record<string, unknown>): void;
  warn(message: string, data?: Record<string, unknown>): void;
  error(message: string, data?: Record<string, unknown>): void;
  debug(message: string, data?: Record<string, unknown>): void;
}

export interface PluginStorage {
  get(key: string): Promise<string | null>;
  set(key: string, value: string, ttlSeconds?: number): Promise<void>;
  delete(key: string): Promise<void>;
}

export interface PluginHttpClient {
  get<T>(url: string, headers?: Record<string, string>): Promise<T>;
  post<T>(url: string, body: unknown, headers?: Record<string, string>): Promise<T>;
  put<T>(url: string, body: unknown, headers?: Record<string, string>): Promise<T>;
  delete<T>(url: string, headers?: Record<string, string>): Promise<T>;
}

export interface SocialPlugin extends PluginBase {
  category: 'social';
  authenticate(context: PluginContext): Promise<AuthResult>;
  publish(context: PluginContext, content: ContentPayload): Promise<PublishResult>;
  schedule(context: PluginContext, content: ContentPayload, scheduledAt: Date): Promise<ScheduleResult>;
  getAnalytics(context: PluginContext, postId: string, dateRange: DateRange): Promise<AnalyticsData>;
  getProfile(context: PluginContext): Promise<PlatformProfile>;
  deletePost(context: PluginContext, postId: string): Promise<void>;
}

export interface AIPlugin extends PluginBase {
  category: 'ai';
  generateCaption(context: PluginContext, input: CaptionInput): Promise<string>;
  generateTitle(context: PluginContext, input: TitleInput): Promise<string>;
  generateThumbnail(context: PluginContext, input: ThumbnailInput): Promise<MediaResult>;
  translate(context: PluginContext, text: string, targetLang: string): Promise<string>;
  rewrite(context: PluginContext, text: string, style: string): Promise<string>;
  predictTrend(context: PluginContext, niche: string): Promise<TrendData>;
  predictViral(context: PluginContext, content: string): Promise<ViralScore>;
}

export interface StoragePlugin extends PluginBase {
  category: 'storage';
  upload(context: PluginContext, file: FileUpload): Promise<StorageResult>;
  download(context: PluginContext, fileId: string): Promise<FileDownload>;
  delete(context: PluginContext, fileId: string): Promise<void>;
  getSignedUrl(context: PluginContext, fileId: string, expiresIn: number): Promise<string>;
  list(context: PluginContext, prefix: string): Promise<FileListResult>;
}

export interface PluginBase {
  metadata: PluginMetadata;
  initialize(context: PluginContext): Promise<void>;
  healthCheck(): Promise<boolean>;
  destroy(): Promise<void>;
}

export interface AuthResult {
  success: boolean;
  accessToken?: string;
  refreshToken?: string;
  expiresAt?: Date;
  scopes?: string[];
  error?: string;
}

export interface ContentPayload {
  text: string;
  mediaIds?: string[];
  hashtags?: string[];
  mentions?: string[];
  link?: string;
  platformSpecific?: Record<string, unknown>;
}

export interface PublishResult {
  success: boolean;
  postId?: string;
  postUrl?: string;
  publishedAt?: Date;
  error?: string;
}

export interface ScheduleResult {
  success: boolean;
  scheduledId?: string;
  scheduledAt: Date;
  error?: string;
}

export interface AnalyticsData {
  impressions: number;
  reach: number;
  engagement: number;
  likes: number;
  comments: number;
  shares: number;
  saves?: number;
  clicks?: number;
  videoViews?: number;
  watchTime?: number;
  followerChange?: number;
}

export interface DateRange {
  start: Date;
  end: Date;
}

export interface PlatformProfile {
  id: string;
  username: string;
  displayName: string;
  avatar?: string;
  followers: number;
  following?: number;
  bio?: string;
  verified?: boolean;
}

export interface CaptionInput {
  topic: string;
  tone?: string;
  platform: string;
  maxLength?: number;
  hashtags?: string[];
  language?: string;
}

export interface TitleInput {
  topic: string;
  platform: string;
  maxLength?: number;
  style?: string;
}

export interface ThumbnailInput {
  text: string;
  style?: string;
  dimensions?: { width: number; height: number };
  brandColors?: string[];
}

export interface MediaResult {
  url: string;
  mimeType: string;
  size: number;
  width?: number;
  height?: number;
}

export interface TrendData {
  trends: TrendItem[];
  niche: string;
  dateRange: DateRange;
}

export interface TrendItem {
  topic: string;
  score: number;
  direction: 'rising' | 'stable' | 'declining';
  relatedHashtags: string[];
}

export interface ViralScore {
  score: number;
  factors: ViralFactor[];
  suggestions: string[];
}

export interface ViralFactor {
  name: string;
  score: number;
  impact: 'high' | 'medium' | 'low';
}

export interface FileUpload {
  name: string;
  mimeType: string;
  size: number;
  buffer: Buffer;
  path?: string;
}

export interface StorageResult {
  fileId: string;
  url: string;
  mimeType: string;
  size: number;
}

export interface FileDownload {
  buffer: Buffer;
  mimeType: string;
  size: number;
}

export interface FileListResult {
  files: FileItem[];
  nextToken?: string;
}

export interface FileItem {
  fileId: string;
  name: string;
  mimeType: string;
  size: number;
  createdAt: Date;
  url: string;
}
