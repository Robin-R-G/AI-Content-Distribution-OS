# Phase 7: Integrations Prompts

## 7.1 Generate Plugin Framework

**Phase:** 7-Integrations
**Output:** `lib/features/social_accounts/data/plugins/`
**Inputs:** Integration requirements, platform APIs

```
Generate plugin framework for Social Media AI integrations.

## Plugin Architecture

### Plugin Interface
```typescript
interface SocialPlugin {
  id: string;
  name: string;
  version: string;
  platforms: Platform[];
  
  // Authentication
  getAuthUrl(state: string): string;
  handleCallback(code: string, state: string): Promise<TokenPair>;
  refreshToken(refreshToken: string): Promise<TokenPair>;
  
  // Account Management
  getAccountInfo(token: string): Promise<AccountInfo>;
  verifyPermissions(token: string): Promise<Permission[]>;
  
  // Content Publishing
  publishPost(post: Post, token: string): Promise<PublishResult>;
  deletePost(platformPostId: string, token: string): Promise<void>;
  
  // Analytics
  getPostMetrics(postId: string, token: string): Promise<PostMetrics>;
  getAccountMetrics(token: string): Promise<AccountMetrics>;
  
  // Webhooks
  verifyWebhookSignature(signature: string, payload: string): boolean;
  parseWebhookEvent(payload: string): WebhookEvent[];
}
```

### Plugin Registry
```typescript
class PluginRegistry {
  private plugins: Map<string, SocialPlugin>;
  
  register(plugin: SocialPlugin): void {
    this.plugins.set(plugin.id, plugin);
  }
  
  get(platform: Platform): SocialPlugin {
    const plugin = this.plugins.get(platform);
    if (!plugin) throw new PluginNotFoundError(platform);
    return plugin;
  }
  
  getAll(): SocialPlugin[] {
    return Array.from(this.plugins.values());
  }
}
```

### Base Plugin Class
```typescript
abstract class BasePlugin implements SocialPlugin {
  abstract id: string;
  abstract name: string;
  abstract version: string;
  abstract platforms: Platform[];
  
  protected httpClient: HttpClient;
  protected config: PluginConfig;
  
  constructor(config: PluginConfig) {
    this.config = config;
    this.httpClient = new HttpClient({
      baseURL: this.config.baseURL,
      headers: this.config.headers
    });
  }
  
  abstract getAuthUrl(state: string): string;
  abstract handleCallback(code: string, state: string): Promise<TokenPair>;
  abstract refreshToken(refreshToken: string): Promise<TokenPair>;
  abstract getAccountInfo(token: string): Promise<AccountInfo>;
  abstract publishPost(post: Post, token: string): Promise<PublishResult>;
  
  // Common implementations
  async verifyPermissions(token: string): Promise<Permission[]> {
    // Default implementation
    return [];
  }
  
  async deletePost(platformPostId: string, token: string): Promise<void> {
    // Default implementation - platform may not support
    throw new NotImplementedError('deletePost');
  }
  
  verifyWebhookSignature(signature: string, payload: string): boolean {
    // Default implementation
    return true;
  }
}
```

### Token Management
```typescript
class TokenManager {
  private storage: TokenStorage;
  
  async getValidToken(accountId: string): Promise<string> {
    const token = await this.storage.get(accountId);
    
    if (this.isExpired(token)) {
      const refreshed = await this.refreshToken(token);
      await this.storage.update(accountId, refreshed);
      return refreshed.accessToken;
    }
    
    return token.accessToken;
  }
  
  private isExpired(token: TokenPair): boolean {
    return token.expiresAt < Date.now();
  }
}
```

### Publishing Service
```typescript
class PublishingService {
  private registry: PluginRegistry;
  private tokenManager: TokenManager;
  
  async publish(post: Post, accountIds: string[]): Promise<PublishResult[]> {
    const results: PublishResult[] = [];
    
    for (const accountId of accountIds) {
      const account = await this.getAccount(accountId);
      const plugin = this.registry.get(account.platform);
      const token = await this.tokenManager.getValidToken(accountId);
      
      try {
        const result = await plugin.publishPost(post, token);
        results.push(result);
      } catch (error) {
        results.push({
          success: false,
          error: error.message
        });
      }
    }
    
    return results;
  }
}
```

Generate complete plugin framework with base classes and registry.
```

**Expected Output:** Complete plugin framework with interfaces, base classes, and registry.

---

## 7.2 Generate YouTube Plugin

**Phase:** 7-Integrations
**Output:** `lib/features/social_accounts/data/plugins/youtube_plugin.dart`
**Inputs:** YouTube API specs

```
Generate YouTube integration plugin for Social Media AI.

## YouTube Plugin Implementation

### OAuth Configuration
```typescript
const youtubeConfig = {
  authUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenUrl: 'https://oauth2.googleapis.com/token',
  scopes: [
    'https://www.googleapis.com/auth/youtube',
    'https://www.googleapis.com/auth/youtube.upload',
    'https://www.googleapis.com/auth/youtube.readonly',
    'https://www.googleapis.com/auth/yt-analytics.readonly'
  ]
};
```

### Account Info
```typescript
async getAccountInfo(token: string): Promise<AccountInfo> {
  const response = await this.httpClient.get(
    '/youtube/v3/channels',
    {
      params: {
        part: 'snippet,statistics',
        mine: true
      },
      headers: { Authorization: `Bearer ${token}` }
    }
  );
  
  const channel = response.items[0];
  return {
    id: channel.id,
    username: channel.snippet.title,
    displayName: channel.snippet.title,
    avatarUrl: channel.snippet.thumbnails.default.url,
    followers: parseInt(channel.statistics.subscriberCount),
    verified: channel.statistics.hiddenSubscriberCount === false
  };
}
```

### Publish Video
```typescript
async publishPost(post: Post, token: string): Promise<PublishResult> {
  // Upload video
  const uploadResponse = await this.uploadVideo(post.media[0], token);
  
  // Update video metadata
  await this.updateVideoMetadata(uploadResponse.id, {
    title: post.content.title,
    description: post.content.description,
    tags: post.content.hashtags,
    categoryId: post.content.categoryId || '22'
  }, token);
  
  return {
    success: true,
    platformPostId: uploadResponse.id,
    url: `https://youtube.com/watch?v=${uploadResponse.id}`
  };
}

private async uploadVideo(video: Media, token: string): Promise<UploadResult> {
  const formData = new FormData();
  formData.append('video', video.file);
  formData.append('metadata', JSON.stringify({
    snippet: {
      title: video.title,
      description: video.description
    },
    status: {
      privacyStatus: 'public'
    }
  }));
  
  const response = await this.httpClient.post(
    'https://www.googleapis.com/upload/youtube/v3/videos',
    formData,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'multipart/form-data'
      },
      params: {
        uploadType: 'multipart',
        part: 'snippet,status'
      }
    }
  );
  
  return response;
}
```

### Get Analytics
```typescript
async getPostMetrics(postId: string, token: string): Promise<PostMetrics> {
  const response = await this.httpClient.get(
    '/youtube/v3/videos',
    {
      params: {
        part: 'statistics',
        id: postId
      },
      headers: { Authorization: `Bearer ${token}` }
    }
  );
  
  const stats = response.items[0].statistics;
  return {
    views: parseInt(stats.viewCount),
    likes: parseInt(stats.likeCount),
    comments: parseInt(stats.commentCount),
    shares: 0 // YouTube doesn't provide share count via API
  };
}
```

### Webhook Handling
```typescript
verifyWebhookSignature(signature: string, payload: string): boolean {
  // YouTube uses PubSubHubbub
  // Verify with X-Hub-Signature header
  const expectedSignature = crypto
    .createHmac('sha1', this.config.webhookSecret)
    .update(payload)
    .digest('hex');
  
  return signature === `sha1=${expectedSignature}`;
}

parseWebhookEvent(payload: string): WebhookEvent[] {
  // Parse Atom feed
  // Extract video published events
  return [];
}
```

Generate complete YouTube plugin with all methods.
```

**Expected Output:** Complete YouTube plugin with OAuth, publishing, and analytics.

---

## 7.3 Generate Instagram Plugin

**Phase:** 7-Integrations
**Output:** Instagram plugin
**Inputs:** Instagram Graph API specs

```
Generate Instagram integration plugin for Social Media AI.

## Instagram Plugin Implementation

### OAuth Configuration
```typescript
const instagramConfig = {
  authUrl: 'https://www.facebook.com/v18.0/dialog/oauth',
  tokenUrl: 'https://graph.facebook.com/v18.0/oauth/access_token',
  scopes: [
    'instagram_basic',
    'instagram_content_publish',
    'instagram_manage_comments',
    'instagram_manage_insights',
    'pages_show_list',
    'pages_read_engagement'
  ]
};
```

### Account Info
```typescript
async getAccountInfo(token: string): Promise<AccountInfo> {
  // Get Facebook Pages
  const pages = await this.httpClient.get('/me/accounts', {
    params: { access_token: token }
  });
  
  // Get Instagram Business Account
  const page = pages.data[0];
  const igAccount = await this.httpClient.get(`/${page.id}`, {
    params: {
      fields: 'instagram_business_account',
      access_token: token
    }
  });
  
  // Get Instagram profile
  const profile = await this.httpClient.get(
    `/${igAccount.instagram_business_account.id}`,
    {
      params: {
        fields: 'id,username,name,profile_picture_url,followers_count',
        access_token: token
      }
    }
  );
  
  return {
    id: profile.id,
    username: profile.username,
    displayName: profile.name,
    avatarUrl: profile.profile_picture_url,
    followers: profile.followers_count,
    platform: 'instagram'
  };
}
```

### Publish Post
```typescript
async publishPost(post: Post, token: string): Promise<PublishResult> {
  // Step 1: Create media container
  const container = await this.createMediaContainer(post, token);
  
  // Step 2: Publish container
  const publish = await this.httpClient.post(
    `/me/media_publish`,
    {
      creation_id: container.id,
      access_token: token
    }
  );
  
  return {
    success: true,
    platformPostId: publish.id,
    url: `https://instagram.com/p/${publish.id}`
  };
}

private async createMediaContainer(post: Post, token: string): Promise<Container> {
  const params: any = {
    access_token: token
  };
  
  if (post.media_type === 'image') {
    params.image_url = post.media[0].url;
    params.caption = this.formatCaption(post);
  } else if (post.media_type === 'video') {
    params.video_url = post.media[0].url;
    params.caption = this.formatCaption(post);
  } else if (post.media_type === 'carousel') {
    // Create carousel container
    params.media_type = 'CAROUSEL';
    params.children = post.media.map(m => m.id).join(',');
    params.caption = this.formatCaption(post);
  }
  
  const response = await this.httpClient.post('/me/media', params);
  return response;
}
```

### Get Analytics
```typescript
async getPostMetrics(postId: string, token: string): Promise<PostMetrics> {
  const response = await this.httpClient.get(`/${postId}`, {
    params: {
      fields: 'like_count,comments_count,impressions,reach,engagement',
      access_token: token
    }
  });
  
  return {
    likes: response.like_count,
    comments: response.comments_count,
    impressions: response.impressions,
    reach: response.reach,
    engagement: response.engagement
  };
}

async getAccountMetrics(token: string): Promise<AccountMetrics> {
  const account = await this.getAccountInfo(token);
  
  const response = await this.httpClient.get(`/${account.id}/insights`, {
    params: {
      metric: 'impressions,reach,profile_views,follower_count',
      period: 'day',
      access_token: token
    }
  });
  
  return {
    impressions: response.data[0].values[0].value,
    reach: response.data[1].values[0].value,
    profileViews: response.data[2].values[0].value,
    followerCount: response.data[3].values[0].value
  };
}
```

### Webhook Handling
```typescript
async handleWebhook(body: any): Promise<WebhookEvent[]> {
  const events: WebhookEvent[] = [];
  
  for (const entry of body.entry) {
    for (const change of entry.changes) {
      if (change.field === 'comments') {
        events.push({
          type: 'comment',
          postId: change.value.post_id,
          commentId: change.value.comment_id,
          text: change.value.text
        });
      }
      
      if (change.field === 'mentions') {
        events.push({
          type: 'mention',
          postId: change.value.post_id,
          mentionedBy: change.value.from
        });
      }
    }
  }
  
  return events;
}
```

Generate complete Instagram plugin with all methods.
```

**Expected Output:** Complete Instagram plugin with Graph API integration.

---

## 7.4 Generate Twitter Plugin

**Phase:** 7-Integrations
**Output:** Twitter plugin
**Inputs:** Twitter API v2 specs

```
Generate Twitter/X integration plugin for Social Media AI.

## Twitter Plugin Implementation

### OAuth Configuration
```typescript
const twitterConfig = {
  authUrl: 'https://twitter.com/i/oauth2/authorize',
  tokenUrl: 'https://api.twitter.com/2/oauth2/token',
  scopes: [
    'tweet.read',
    'tweet.write',
    'users.read',
    'offline.access'
  ]
};
```

### Publish Tweet
```typescript
async publishPost(post: Post, token: string): Promise<PublishResult> {
  const tweetData: any = {
    text: this.formatTweet(post)
  };
  
  // Add media if present
  if (post.media && post.media.length > 0) {
    const mediaIds = await this.uploadMedia(post.media, token);
    tweetData.media = { media_ids: mediaIds };
  }
  
  // Add poll if present
  if (post.content.poll) {
    tweetData.poll = {
      options: post.content.poll.options,
      duration_minutes: post.content.poll.duration || 1440
    };
  }
  
  const response = await this.httpClient.post('/2/tweets', tweetData, {
    headers: { Authorization: `Bearer ${token}` }
  });
  
  return {
    success: true,
    platformPostId: response.data.id,
    url: `https://twitter.com/i/status/${response.data.id}`
  };
}

private formatTweet(post: Post): string {
  let text = post.content.text;
  
  // Add hashtags
  if (post.content.hashtags && post.content.hashtags.length > 0) {
    text += '\n\n' + post.content.hashtags.map(h => `#${h}`).join(' ');
  }
  
  // Truncate if needed (280 chars)
  if (text.length > 280) {
    text = text.substring(0, 277) + '...';
  }
  
  return text;
}
```

### Get Analytics
```typescript
async getPostMetrics(postId: string, token: string): Promise<PostMetrics> {
  const response = await this.httpClient.get(`/2/tweets/${postId}`, {
    params: {
      'tweet.fields': 'public_metrics,created_at'
    },
    headers: { Authorization: `Bearer ${token}` }
  });
  
  const metrics = response.data.public_metrics;
  return {
    likes: metrics.like_count,
    retweets: metrics.retweet_count,
    replies: metrics.reply_count,
    quotes: metrics.quote_count,
    impressions: metrics.impression_count
  };
}
```

### Delete Tweet
```typescript
async deletePost(platformPostId: string, token: string): Promise<void> {
  await this.httpClient.delete(`/2/tweets/${platformPostId}`, {
    headers: { Authorization: `Bearer ${token}` }
  });
}
```

Generate complete Twitter plugin with all methods.
```

**Expected Output:** Complete Twitter plugin with tweet publishing and analytics.

---

## 7.5 Generate LinkedIn Plugin

**Phase:** 7-Integrations
**Output:** LinkedIn plugin
**Inputs:** LinkedIn API specs

```
Generate LinkedIn integration plugin for Social Media AI.

## LinkedIn Plugin Implementation

### OAuth Configuration
```typescript
const linkedinConfig = {
  authUrl: 'https://www.linkedin.com/oauth/v2/authorization',
  tokenUrl: 'https://www.linkedin.com/oauth/v2/accessToken',
  scopes: [
    'w_member_social',
    'r_liteprofile',
    'r_emailaddress'
  ]
};
```

### Publish Post
```typescript
async publishPost(post: Post, token: string): Promise<PublishResult> {
  const author = await this.getAuthorURN(token);
  
  const postData: any = {
    author: author,
    lifecycleState: 'PUBLISHED',
    specificContent: {
      'com.linkedin.ugc.ShareContent': {
        shareCommentary: {
          text: this.formatLinkedInPost(post)
        },
        shareMediaCategory: this.getMediaCategory(post)
      }
    },
    visibility: {
      'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC'
    }
  };
  
  // Add media if present
  if (post.media && post.media.length > 0) {
    const mediaUrn = await this.registerMedia(post.media[0], token);
    postData.specificContent['com.linkedin.ugc.ShareContent'].media = [{
      status: 'READY',
      media: mediaUrn,
      title: {
        text: post.content.title || ''
      }
    }];
  }
  
  const response = await this.httpClient.post(
    '/ugcPosts',
    postData,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'X-Restli-Protocol-Version': '2.0.0'
      }
    }
  );
  
  return {
    success: true,
    platformPostId: response.id,
    url: `https://linkedin.com/feed/update/${response.id}`
  };
}
```

### Get Analytics
```typescript
async getPostMetrics(postId: string, token: string): Promise<PostMetrics> {
  const response = await this.httpClient.get(
    `/organizationalEntityShareStatistics`,
    {
      params: {
        q: 'organizationalEntity',
        organizationalEntity: postId
      },
      headers: { Authorization: `Bearer ${token}` }
    }
  );
  
  const stats = response.elements[0];
  return {
    likes: stats.totalShareStatistics.likeCount,
    comments: stats.totalShareStatistics.commentCount,
    shares: stats.totalShareStatistics.shareCount,
    impressions: stats.totalShareStatistics.impressionCount
  };
}
```

Generate complete LinkedIn plugin with all methods.
```

**Expected Output:** Complete LinkedIn plugin with professional content publishing.

---

## 7.6 Generate TikTok Plugin

**Phase:** 7-Integrations
**Output:** TikTok plugin
**Inputs:** TikTok API specs

```
Generate TikTok integration plugin for Social Media AI.

## TikTok Plugin Implementation

### OAuth Configuration
```typescript
const tiktokConfig = {
  authUrl: 'https://www.tiktok.com/v2/auth/authorize/',
  tokenUrl: 'https://open.tiktokapis.com/v2/oauth/token/',
  scopes: [
    'user.info.basic',
    'user.info.profile',
    'video.publish',
    'video.list'
  ]
};
```

### Publish Video
```typescript
async publishPost(post: Post, token: string): Promise<PublishResult> {
  // Step 1: Get upload URL
  const uploadUrl = await this.getUploadUrl(token);
  
  // Step 2: Upload video
  const uploadResult = await this.uploadVideo(post.media[0], uploadUrl);
  
  // Step 3: Publish
  const response = await this.httpClient.post(
    '/v2/publish/video/publish/',
    {
      post_info: {
        title: this.formatTitle(post),
        privacy_level: post.content.privacy || 'PUBLIC_TO_EVERYONE',
        disable_duet: post.content.disableDuet || false,
        disable_comment: post.content.disableComment || false,
        disable_stitch: post.content.disableStitch || false
      },
      source_info: {
        source: 'FILE_UPLOAD',
        video_id: uploadResult.video_id
      }
    },
    {
      headers: { Authorization: `Bearer ${token}` }
    }
  );
  
  return {
    success: true,
    platformPostId: response.data.publish_id,
    url: `https://tiktok.com/@user/video/${response.data.publish_id}`
  };
}
```

### Get Analytics
```typescript
async getPostMetrics(postId: string, token: string): Promise<PostMetrics> {
  const response = await this.httpClient.get(
    '/v2/video/list/',
    {
      params: { fields: 'id,title,share_url,statistics' },
      headers: { Authorization: `Bearer ${token}` }
    }
  );
  
  const video = response.data.videos.find(v => v.id === postId);
  return {
    views: video.statistics.play_count,
    likes: video.statistics.like_count,
    comments: video.statistics.comment_count,
    shares: video.statistics.share_count
  };
}
```

Generate complete TikTok plugin with all methods.
```

**Expected Output:** Complete TikTok plugin with video publishing and analytics.

---

## 7.7 Generate Storage Plugins

**Phase:** 7-Integrations
**Output:** Storage abstraction layer
**Inputs:** Storage requirements

```
Generate storage plugin system for Social Media AI.

## Storage Plugin Interface

```typescript
interface StoragePlugin {
  id: string;
  name: string;
  
  // Upload
  upload(file: File, path: string): Promise<StorageResult>;
  uploadBuffer(buffer: Buffer, path: string, contentType: string): Promise<StorageResult>;
  
  // Download
  download(path: string): Promise<Buffer>;
  getSignedUrl(path: string, expiresIn?: number): Promise<string>;
  
  // Management
  delete(path: string): Promise<void>;
  exists(path: string): Promise<boolean>;
  getMetadata(path: string): Promise<FileMetadata>;
  
  // List
  list(prefix: string): Promise<FileItem[]>;
}
```

## Supabase Storage Plugin

```typescript
class SupabaseStoragePlugin implements StoragePlugin {
  private client: SupabaseClient;
  private bucket: string;
  
  async upload(file: File, path: string): Promise<StorageResult> {
    const { data, error } = await this.client.storage
      .from(this.bucket)
      .upload(path, file, {
        cacheControl: '31536000',
        upsert: false
      });
    
    if (error) throw error;
    
    return {
      path: data.path,
      url: this.getPublicUrl(data.path),
      size: file.size,
      contentType: file.type
    };
  }
  
  async getSignedUrl(path: string, expiresIn: number = 3600): Promise<string> {
    const { data } = await this.client.storage
      .from(this.bucket)
      .createSignedUrl(path, expiresIn);
    
    return data.signedUrl;
  }
}
```

## S3 Storage Plugin

```typescript
class S3StoragePlugin implements StoragePlugin {
  private client: S3Client;
  private bucket: string;
  
  async upload(file: File, path: string): Promise<StorageResult> {
    await this.client.send(new PutObjectCommand({
      Bucket: this.bucket,
      Key: path,
      Body: file.buffer,
      ContentType: file.type,
      CacheControl: 'max-age=31536000'
    }));
    
    return {
      path,
      url: `https://${this.bucket}.s3.amazonaws.com/${path}`,
      size: file.size,
      contentType: file.type
    };
  }
}
```

## Cloudflare R2 Plugin

```typescript
class R2StoragePlugin implements StoragePlugin {
  private client: S3Client;
  private bucket: string;
  
  constructor() {
    this.client = new S3Client({
      endpoint: `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: ACCESS_KEY_ID,
        secretAccessKey: SECRET_ACCESS_KEY
      }
    });
  }
  
  // Implement interface methods
}
```

## Local Storage Plugin (Development)

```typescript
class LocalStoragePlugin implements StoragePlugin {
  private basePath: string;
  
  async upload(file: File, path: string): Promise<StorageResult> {
    const fullPath = path.join(this.basePath, path);
    await fs.promises.mkdir(path.dirname(fullPath), { recursive: true });
    await fs.promises.writeFile(fullPath, file.buffer);
    
    return {
      path,
      url: `file://${fullPath}`,
      size: file.size,
      contentType: file.type
    };
  }
}
```

## Media Processing Pipeline

```typescript
class MediaProcessor {
  async processImage(file: File): Promise<ProcessedImage> {
    // Generate thumbnails
    const thumbnail = await this.resize(file, 200, 200);
    
    // Optimize
    const optimized = await this.optimize(file, {
      quality: 85,
      format: 'webp'
    });
    
    // Generate blur hash
    const blurHash = await this.generateBlurHash(file);
    
    return {
      original: file,
      thumbnail,
      optimized,
      blurHash
    };
  }
  
  async processVideo(file: File): Promise<ProcessedVideo> {
    // Generate thumbnail
    const thumbnail = await this.extractThumbnail(file);
    
    // Generate preview
    const preview = await this.createPreview(file, 5);
    
    return {
      original: file,
      thumbnail,
      preview,
      duration: await this.getDuration(file)
    };
  }
}
```

Generate complete storage plugin system with multiple providers.
```

**Expected Output:** Complete storage plugin system with Supabase, S3, R2, and local storage.
