# CDN Configuration

## Cloudflare CDN Setup

### Domain Configuration

```
contentos.ai          → Main application (Flutter Web)
api.contentos.ai      → API Gateway (Cloudflare Workers)
media.contentos.ai    → Media storage (R2 public access)
admin.contentos.ai    → Admin panel
```

### DNS Records

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | @ | 192.0.2.1 | Yes |
| CNAME | www | contentos.ai | Yes |
| CNAME | api | workers.dev | Yes |
| CNAME | media | r2.dev | Yes |
| CNAME | admin | pages.dev | Yes |

### Zone Settings

```typescript
// cloudflare-zone-config.ts
const zoneConfig = {
  // Security
  ssl: 'strict',
  minTlsVersion: '1.2',
  alwaysUseHttps: true,
  automaticHttpsRewrites: true,

  // Performance
  brotli: true,
  earlyHints: true,
  http2: true,
  http3: true,

  // Caching
  cacheLevel: 'aggressive',
  browserCacheTtl: 14400, // 4 hours
  edgeCacheTtl: 7200, // 2 hours

  // Security Headers
  securityHeaders: {
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=()'
  }
};
```

## Cache Rules

### Page Rules

```typescript
const pageRules = [
  {
    target: 'contentos.ai/api/*',
    settings: {
      cacheLevel: 'bypass',
      disablePerformance: true
    }
  },
  {
    target: 'media.contentos.ai/*',
    settings: {
      cacheLevel: 'aggressive',
      edgeCacheTtl: 2592000, // 30 days
      browserCacheTtl: 2592000,
      polish: 'lossy',
      webp: 'on',
      Mirage: true
    }
  },
  {
    target: 'contentos.ai/assets/*',
    settings: {
      cacheLevel: 'aggressive',
      edgeCacheTtl: 31536000, // 1 year
      browserCacheTtl: 31536000
    }
  }
];
```

### Cache Rules (New Format)

```typescript
const cacheRules = [
  {
    name: 'API Bypass',
    expression: '(http.host eq "api.contentos.ai")',
    action: 'set_cache_settings',
    settings: {
      cache: false
    }
  },
  {
    name: 'Static Assets',
    expression: '(http.request.uri.path matches "^/assets/.*")',
    action: 'set_cache_settings',
    settings: {
      cache: true,
      edge_ttl: 31536000,
      browser_ttl: 31536000,
      serve_stale: true
    }
  },
  {
    name: 'Images',
    expression: '(http.request.uri.path matches ".*\\.(jpg|jpeg|png|gif|webp|svg)$")',
    action: 'set_cache_settings',
    settings: {
      cache: true,
      edge_ttl: 2592000,
      browser_ttl: 2592000,
      polish: 'lossy',
      webp: 'on'
    }
  },
  {
    name: 'Media CDN',
    expression: '(http.host eq "media.contentos.ai")',
    action: 'set_cache_settings',
    settings: {
      cache: true,
      edge_ttl: 2592000,
      browser_ttl: 2592000
    }
  }
];
```

## Edge Functions

### Cloudflare Workers Setup

```typescript
// workers/router.ts
interface Env {
  API_URL: string;
  R2_BUCKET: R2Bucket;
  CACHE: KVNamespace;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Route to appropriate handler
    if (url.pathname.startsWith('/api/')) {
      return handleAPI(request, env);
    }

    if (url.pathname.startsWith('/media/')) {
      return handleMedia(request, env);
    }

    // Default: serve static assets
    return handleStatic(request, env);
  }
};

// API proxy
async function handleAPI(request: Request, env: Env): Promise<Response> {
  const apiUrl = new URL(env.API_URL);
  apiUrl.pathname = request.url;

  const response = await fetch(apiUrl.toString(), {
    method: request.method,
    headers: request.headers,
    body: request.body
  });

  return response;
}

// Media proxy with caching
async function handleMedia(request: Request, env: Env): Promise<Response> {
  const cache = caches.default;
  const cacheKey = new Request(request.url, request);

  // Check cache
  let response = await cache.match(cacheKey);
  if (response) return response;

  // Fetch from R2
  const key = request.url.replace('https://media.contentos.ai/', '');
  const object = await env.R2_BUCKET.get(key);

  if (!object) {
    return new Response('Not Found', { status: 404 });
  }

  response = new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata.contentType || 'application/octet-stream',
      'Cache-Control': 'public, max-age=2592000',
      'CDN-Cache-Control': 'public, max-age=2592000'
    }
  });

  // Cache response
  await cache.put(cacheKey, response.clone());

  return response;
}
```

### Edge Functions for Optimization

```typescript
// workers/image-optimization.ts
export async function optimizeImage(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const width = parseInt(url.searchParams.get('w') || '0');
  const height = parseInt(url.searchParams.get('h') || '0');
  const quality = parseInt(url.searchParams.get('q') || '80');
  const format = url.searchParams.get('f') || 'auto';

  // Generate cache key
  const cacheKey = `img:${url.pathname}:${width}:${height}:${quality}:${format}`;

  // Check cache
  const cached = await env.CACHE.get(cacheKey, 'arrayBuffer');
  if (cached) {
    return new Response(cached, {
      headers: {
        'Content-Type': `image/${format === 'auto' ? 'webp' : format}`,
        'Cache-Control': 'public, max-age=2592000'
      }
    });
  }

  // Fetch original image
  const key = url.pathname.replace('/images/', '');
  const object = await env.R2_BUCKET.get(key);

  if (!object) {
    return new Response('Not Found', { status: 404 });
  }

  // Process with Cloudflare Image Resizing
  const imageRequest = new Request(request.url, {
    ...request,
    cf: {
      image: {
        width: width || undefined,
        height: height || undefined,
        quality: quality,
        format: format === 'auto' ? undefined : format,
        fit: 'scale-down'
      }
    }
  });

  const response = await fetch(imageRequest);

  // Cache the result
  const responseBuffer = await response.arrayBuffer();
  await env.CACHE.put(cacheKey, responseBuffer, {
    expirationTtl: 2592000
  });

  return new Response(responseBuffer, {
    headers: {
      'Content-Type': response.headers.get('Content-Type') || 'image/webp',
      'Cache-Control': 'public, max-age=2592000'
    }
  });
}
```

## Image Optimization

### Image Processing Pipeline

```typescript
// lib/cdn/image-pipeline.ts
export class ImagePipeline {
  private cdnBaseUrl = 'https://media.contentos.ai';

  // Generate optimized image URLs
  getOptimizedUrl(
    originalUrl: string,
    options: ImageOptions = {}
  ): string {
    const url = new URL(originalUrl);
    const params = new URLSearchParams();

    if (options.width) params.set('w', options.width.toString());
    if (options.height) params.set('h', options.height.toString());
    if (options.quality) params.set('q', options.quality.toString());
    if (options.format) params.set('f', options.format);

    return `${url.pathname}?${params.toString()}`;
  }

  // Platform-specific sizes
  getPlatformSizes(platform: string): Record<string, ImageOptions> {
    const sizes: Record<string, Record<string, ImageOptions>> = {
      twitter: {
        post: { width: 1200, height: 675, quality: 85 },
        profile: { width: 400, height: 400, quality: 85 },
        header: { width: 1500, height: 500, quality: 85 }
      },
      instagram: {
        post: { width: 1080, height: 1080, quality: 85 },
        story: { width: 1080, height: 1920, quality: 85 },
        profile: { width: 320, height: 320, quality: 85 }
      },
      linkedin: {
        post: { width: 1200, height: 627, quality: 85 },
        profile: { width: 400, height: 400, quality: 85 },
        cover: { width: 1584, height: 396, quality: 85 }
      },
      facebook: {
        post: { width: 1200, height: 630, quality: 85 },
        profile: { width: 170, height: 170, quality: 85 },
        cover: { width: 820, height: 312, quality: 85 }
      }
    };

    return sizes[platform] || {};
  }

  // Generate responsive srcset
  generateSrcSet(originalUrl: string): string {
    const sizes = [320, 640, 768, 1024, 1280, 1536];
    return sizes
      .map(size => `${this.getOptimizedUrl(originalUrl, { width: size })} ${size}w`)
      .join(', ');
  }
}
```

### Responsive Images Component

```dart
// lib/shared/widgets/media/responsive_image.dart
import 'package:flutter/material.dart';

class ResponsiveImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ResponsiveImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      getOptimizedUrl(url, context),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.error_outline, color: Colors.grey),
        );
      },
    );
  }

  String getOptimizedUrl(String url, BuildContext context) {
    final width = MediaQuery.of(context).size.width.toInt();
    final pixelRatio = MediaQuery.of(context).devicePixelRatio.toInt();
    final optimalWidth = width * pixelRatio;

    return '$url?w=$optimalWidth&q=80&f=auto';
  }
}
```

## Video Streaming

### Video Configuration

```typescript
// lib/cdn/video-config.ts
export const videoConfig = {
  // Supported formats
  formats: {
    mp4: { codec: 'h264', container: 'mp4' },
    webm: { codec: 'vp9', container: 'webm' },
    hls: { codec: 'h264', container: 'm3u8' }
  },

  // Quality presets
  qualities: [
    { label: '360p', width: 640, height: 360, bitrate: 800000 },
    { label: '480p', width: 854, height: 480, bitrate: 1400000 },
    { label: '720p', width: 1280, height: 720, bitrate: 2800000 },
    { label: '1080p', width: 1920, height: 1080, bitrate: 5000000 }
  ],

  // HLS settings
  hls: {
    segmentDuration: 6,
    playlistWindow: 3,
    encryption: false
  }
};

// Video processing worker
export async function processVideo(inputKey: string, env: Env): Promise<VideoOutput> {
  // Generate multiple qualities
  const outputs: VideoVariant[] = [];

  for (const quality of videoConfig.qualities) {
    const outputKey = inputKey.replace(/\.[^.]+$/, `_${quality.label}.mp4`);

    // Process with FFmpeg (via Cloudflare Stream or external service)
    await processWithFFmpeg(inputKey, outputKey, quality);

    outputs.push({
      key: outputKey,
      quality: quality.label,
      width: quality.width,
      height: quality.height,
      url: `https://media.contentos.ai/${outputKey}`
    });
  }

  // Generate HLS playlist
  const hlsKey = inputKey.replace(/\.[^.]+$/, '.m3u8');
  await generateHLSPlaylist(outputs, hlsKey);

  return {
    original: inputKey,
    variants: outputs,
    hls: `https://media.contentos.ai/${hlsKey}`
  };
}
```

### Video Player Component

```dart
// lib/shared/widgets/media/video_player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;

  const AppVideoPlayer({
    Key? key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
  }) : super(key: key);

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: false,
      ),
    );

    await _controller.initialize();
    setState(() => _isInitialized = true);

    if (widget.autoPlay) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          // Play/Pause button
          if (!_controller.value.isPlaying)
            IconButton(
              iconSize: 64,
              icon: const Icon(Icons.play_circle_filled, color: Colors.white),
              onPressed: () => _controller.play(),
            ),
          // Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```
