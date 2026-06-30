import { v4 as uuidv4 } from 'uuid';
import type {
  AnalyticsSnapshot,
  AnalyticsGoal,
  PlatformMetrics,
  AccountMetrics,
  PostMetrics,
  AudienceDemographics,
  EngagementMetrics,
  GrowthMetrics,
  ContentPerformance,
  DateRange,
  AnalyticsFilter,
} from './types';

export class AnalyticsService {
  private db: any;
  private redis: any;
  private pluginRegistry: any;

  constructor(db: any, redis: any, pluginRegistry: any) {
    this.db = db;
    this.redis = redis;
    this.pluginRegistry = pluginRegistry;
  }

  async getOverview(workspaceId: string, dateRange: DateRange): Promise<AnalyticsSnapshot> {
    const cacheKey = `analytics:overview:${workspaceId}:${dateRange.start}:${dateRange.end}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const accounts = await this.db.account.findMany({ where: { workspaceId } });
    const platforms = await this.getPlatformMetrics(workspaceId, dateRange);

    const overview = {
      totalFollowers: platforms.reduce((sum, p) => sum + p.followers, 0),
      followersGrowth: platforms.reduce((sum, p) => sum + p.followersGrowth, 0),
      totalImpressions: platforms.reduce((sum, p) => sum + p.impressions, 0),
      totalReach: platforms.reduce((sum, p) => sum + p.reach, 0),
      totalEngagement: platforms.reduce((sum, p) => sum + p.engagement, 0),
      avgEngagementRate: platforms.reduce((sum, p) => sum + p.engagementRate, 0) / (platforms.length || 1),
      totalPosts: platforms.reduce((sum, p) => sum + p.posts, 0),
    };

    const snapshot: AnalyticsSnapshot = {
      id: uuidv4(),
      workspaceId,
      dateRange,
      overview,
      platforms,
      accounts: await this.getAccountMetrics(workspaceId, dateRange),
      generatedAt: new Date(),
    };

    await this.redis.setex(cacheKey, 1800, JSON.stringify(snapshot));
    return snapshot;
  }

  async getPlatformAnalytics(platform: string, dateRange: DateRange): Promise<PlatformMetrics[]> {
    return this.db.platformMetric.findMany({
      where: { platform, dateRange: { gte: new Date(dateRange.start), lte: new Date(dateRange.end) } },
      orderBy: { date: 'desc' },
    });
  }

  async getAccountAnalytics(accountId: string, dateRange: DateRange): Promise<AccountMetrics> {
    const account = await this.db.account.findUnique({ where: { id: accountId } });
    if (!account) throw new Error('Account not found');

    const metrics = await this.db.accountMetric.findMany({
      where: { accountId, date: { gte: new Date(dateRange.start), lte: new Date(dateRange.end) } },
    });

    return {
      accountId,
      platform: account.platform,
      username: account.username,
      displayName: account.displayName,
      avatar: account.avatar,
      followers: metrics[0]?.followers ?? 0,
      following: account.following ?? 0,
      posts: metrics.reduce((sum, m) => sum + m.posts, 0),
      engagementRate: metrics.reduce((sum, m) => sum + m.engagementRate, 0) / (metrics.length || 1),
      impressions: metrics.reduce((sum, m) => sum + m.impressions, 0),
      reach: metrics.reduce((sum, m) => sum + m.reach, 0),
      profileViews: metrics.reduce((sum, m) => sum + m.profileViews, 0),
      websiteClicks: metrics.reduce((sum, m) => sum + m.websiteClicks, 0),
    };
  }

  async getPostAnalytics(postId: string): Promise<PostMetrics> {
    const post = await this.db.post.findUnique({ where: { id: postId } });
    if (!post) throw new Error('Post not found');

    return {
      postId: post.id,
      platform: post.platform,
      accountId: post.accountId,
      content: post.content,
      mediaType: post.mediaType,
      postedAt: post.publishedAt,
      impressions: post.impressions ?? 0,
      reach: post.reach ?? 0,
      likes: post.likes ?? 0,
      comments: post.comments ?? 0,
      shares: post.shares ?? 0,
      saves: post.saves ?? 0,
      clicks: post.clicks ?? 0,
      engagementRate: post.engagementRate ?? 0,
    };
  }

  async getAudienceDemographics(workspaceId: string): Promise<AudienceDemographics> {
    const cacheKey = `analytics:demographics:${workspaceId}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const demographics = await this.db.audienceDemographic.findFirst({ where: { workspaceId } });
    const result: AudienceDemographics = demographics ?? {
      age: [], gender: [], location: [], language: [], interests: [], activeHours: [],
    };

    await this.redis.setex(cacheKey, 86400, JSON.stringify(result));
    return result;
  }

  async getEngagementMetrics(workspaceId: string, dateRange: DateRange): Promise<EngagementMetrics> {
    const posts = await this.db.post.findMany({
      where: { workspaceId, publishedAt: { gte: new Date(dateRange.start), lte: new Date(dateRange.end) } },
    });

    const totalEngagement = posts.reduce((sum, p) => sum + (p.likes ?? 0) + (p.comments ?? 0) + (p.shares ?? 0) + (p.saves ?? 0), 0);
    const totalImpressions = posts.reduce((sum, p) => sum + (p.impressions ?? 0), 0);

    return {
      totalEngagement,
      engagementRate: totalImpressions > 0 ? (totalEngagement / totalImpressions) * 100 : 0,
      avgLikes: posts.reduce((sum, p) => sum + (p.likes ?? 0), 0) / (posts.length || 1),
      avgComments: posts.reduce((sum, p) => sum + (p.comments ?? 0), 0) / (posts.length || 1),
      avgShares: posts.reduce((sum, p) => sum + (p.shares ?? 0), 0) / (posts.length || 1),
      avgSaves: posts.reduce((sum, p) => sum + (p.saves ?? 0), 0) / (posts.length || 1),
      topContent: posts.sort((a, b) => (b.engagementRate ?? 0) - (a.engagementRate ?? 0)).slice(0, 10).map(this.toPostMetrics),
      engagementByDay: this.aggregateByDay(posts, 'engagement'),
      engagementByHour: this.aggregateByHour(posts, 'engagement'),
    };
  }

  async getGrowthMetrics(workspaceId: string, dateRange: DateRange): Promise<GrowthMetrics> {
    const snapshots = await this.db.growthSnapshot.findMany({
      where: { workspaceId, date: { gte: new Date(dateRange.start), lte: new Date(dateRange.end) } },
      orderBy: { date: 'asc' },
    });

    const latest = snapshots[snapshots.length - 1];
    const earliest = snapshots[0];

    return {
      followersGrowth: (latest?.followers ?? 0) - (earliest?.followers ?? 0),
      followersGrowthRate: earliest?.followers ? (((latest?.followers ?? 0) - earliest.followers) / earliest.followers) * 100 : 0,
      newFollowers: latest?.newFollowers ?? 0,
      unfollowers: latest?.unfollowers ?? 0,
      netGrowth: (latest?.newFollowers ?? 0) - (latest?.unfollowers ?? 0),
      projectedFollowers: (latest?.followers ?? 0) + ((latest?.newFollowers ?? 0) - (latest?.unfollowers ?? 0)) * 30,
      growthByDay: snapshots.map((s) => ({ date: s.date.toISOString(), followers: s.followers, growth: s.growth ?? 0 })),
    };
  }

  async getContentPerformance(workspaceId: string, dateRange: DateRange): Promise<ContentPerformance> {
    const posts = await this.db.post.findMany({
      where: { workspaceId, publishedAt: { gte: new Date(dateRange.start), lte: new Date(dateRange.end) } },
    });

    const sorted = posts.sort((a, b) => (b.engagementRate ?? 0) - (a.engagementRate ?? 0));
    const avgImpressions = posts.reduce((sum, p) => sum + (p.impressions ?? 0), 0) / (posts.length || 1);
    const avgEngagement = posts.reduce((sum, p) => sum + ((p.likes ?? 0) + (p.comments ?? 0) + (p.shares ?? 0)), 0) / (posts.length || 1);

    const typeBreakdown: Record<string, { count: number; engagement: number }> = {};
    for (const post of posts) {
      const type = post.mediaType ?? 'text';
      if (!typeBreakdown[type]) typeBreakdown[type] = { count: 0, engagement: 0 };
      typeBreakdown[type].count++;
      typeBreakdown[type].engagement += (post.engagementRate ?? 0);
    }

    return {
      topContent: sorted.slice(0, 10).map(this.toPostMetrics),
      avgPerformance: { impressions: avgImpressions, engagement: avgEngagement, engagementRate: avgImpressions > 0 ? (avgEngagement / avgImpressions) * 100 : 0 },
      contentTypeBreakdown: Object.entries(typeBreakdown).map(([type, data]) => ({
        type, count: data.count, avgEngagement: data.engagement / data.count,
      })),
      hashtagPerformance: await this.getHashtagPerformance(workspaceId, dateRange),
      bestPerformingTimes: this.getBestTimesFromPosts(posts),
    };
  }

  async getOptimalTimes(workspaceId: string, platform: string): Promise<Array<{ day: string; hour: number; engagement: number }>> {
    const posts = await this.db.post.findMany({
      where: { workspaceId, platform, status: 'published' },
    });

    const timeMap: Record<string, Record<number, { total: number; count: number }>> = {};
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    for (const post of posts) {
      const date = new Date(post.publishedAt);
      const day = days[date.getDay()];
      const hour = date.getHours();
      if (!timeMap[day]) timeMap[day] = {};
      if (!timeMap[day][hour]) timeMap[day][hour] = { total: 0, count: 0 };
      timeMap[day][hour].total += post.engagementRate ?? 0;
      timeMap[day][hour].count++;
    }

    const result: Array<{ day: string; hour: number; engagement: number }> = [];
    for (const [day, hours] of Object.entries(timeMap)) {
      for (const [hour, data] of Object.entries(hours)) {
        result.push({ day, hour: parseInt(hour), engagement: data.total / data.count });
      }
    }

    return result.sort((a, b) => b.engagement - a.engagement).slice(0, 20);
  }

  async getHashtagPerformance(workspaceId: string, dateRange: DateRange): Promise<Array<{ tag: string; posts: number; avgEngagement: number }>> {
    const posts = await this.db.post.findMany({
      where: { workspaceId, publishedAt: { gte: new Date(dateRange.start), lte: new Date(dateRange.end) } },
      select: { hashtags: true, engagementRate: true },
    });

    const tagMap: Record<string, { posts: number; totalEngagement: number }> = {};
    for (const post of posts) {
      const tags = post.hashtags ?? [];
      for (const tag of tags) {
        if (!tagMap[tag]) tagMap[tag] = { posts: 0, totalEngagement: 0 };
        tagMap[tag].posts++;
        tagMap[tag].totalEngagement += post.engagementRate ?? 0;
      }
    }

    return Object.entries(tagMap)
      .map(([tag, data]) => ({ tag, posts: data.posts, avgEngagement: data.totalEngagement / data.posts }))
      .sort((a, b) => b.avgEngagement - a.avgEngagement)
      .slice(0, 50);
  }

  async generateReport(workspaceId: string, config: { dateRange: DateRange; sections: string[]; format: string }): Promise<any> {
    const snapshot = await this.getOverview(workspaceId, config.dateRange);
    const report = { id: uuidv4(), workspaceId, config, snapshot, generatedAt: new Date() };
    await this.db.report.create({ data: report });
    return report;
  }

  async exportReport(reportId: string, format: 'csv' | 'pdf' | 'json'): Promise<string> {
    const report = await this.db.report.findUnique({ where: { id: reportId } });
    if (!report) throw new Error('Report not found');
    return `/exports/${reportId}.${format}`;
  }

  async fetchFromPlatform(accountId: string, dateRange: DateRange): Promise<void> {
    const account = await this.db.account.findUnique({ where: { id: accountId } });
    if (!account) throw new Error('Account not found');

    const plugin = this.pluginRegistry.get(account.platform);
    if (!plugin) throw new Error(`Plugin not found for ${account.platform}`);

    const metrics = await plugin.getAnalytics(account.accessToken, account.platformAccountId, dateRange);
    await this.db.platformMetric.create({
      data: { id: uuidv4(), accountId, ...metrics, fetchedAt: new Date() },
    });
  }

  private async getPlatformMetrics(workspaceId: string, dateRange: DateRange): Promise<PlatformMetrics[]> {
    const accounts = await this.db.account.findMany({ where: { workspaceId } });
    const platformGroups: Record<string, any[]> = {};
    for (const account of accounts) {
      if (!platformGroups[account.platform]) platformGroups[account.platform] = [];
      platformGroups[account.platform].push(account);
    }

    const results: PlatformMetrics[] = [];
    for (const [platform, platformAccounts] of Object.entries(platformGroups)) {
      const metrics = await Promise.all(
        platformAccounts.map((a) => this.getAccountMetrics(a.id, dateRange))
      );
      results.push({
        platform,
        followers: metrics.reduce((sum, m) => sum + m.followers, 0),
        followersGrowth: metrics.reduce((sum, m) => sum + (m.followersGrowth ?? 0), 0),
        followersGrowthRate: 0,
        impressions: metrics.reduce((sum, m) => sum + m.impressions, 0),
        reach: metrics.reduce((sum, m) => sum + m.reach, 0),
        engagement: metrics.reduce((sum, m) => sum + (m.engagementRate ?? 0), 0),
        engagementRate: metrics.reduce((sum, m) => sum + m.engagementRate, 0) / (metrics.length || 1),
        posts: metrics.reduce((sum, m) => sum + m.posts, 0),
      });
    }
    return results;
  }

  private async getAccountMetrics(workspaceId: string, dateRange: DateRange): Promise<AccountMetrics[]> {
    const accounts = await this.db.account.findMany({ where: { workspaceId } });
    return Promise.all(accounts.map((a) => this.getAccountAnalytics(a.id, dateRange)));
  }

  private toPostMetrics(post: any): PostMetrics {
    return {
      postId: post.id, platform: post.platform, accountId: post.accountId,
      content: post.content, mediaType: post.mediaType, postedAt: post.publishedAt,
      impressions: post.impressions ?? 0, reach: post.reach ?? 0, likes: post.likes ?? 0,
      comments: post.comments ?? 0, shares: post.shares ?? 0, saves: post.saves ?? 0,
      clicks: post.clicks ?? 0, engagementRate: post.engagementRate ?? 0,
    };
  }

  private aggregateByDay(posts: any[], metric: string): Array<{ day: string; engagement: number }> {
    const dayMap: Record<string, number> = {};
    for (const post of posts) {
      const day = new Date(post.publishedAt).toISOString().split('T')[0];
      dayMap[day] = (dayMap[day] || 0) + (post.likes ?? 0) + (post.comments ?? 0) + (post.shares ?? 0);
    }
    return Object.entries(dayMap).map(([day, engagement]) => ({ day, engagement }));
  }

  private aggregateByHour(posts: any[], metric: string): Array<{ hour: number; engagement: number }> {
    const hourMap: Record<number, number> = {};
    for (const post of posts) {
      const hour = new Date(post.publishedAt).getHours();
      hourMap[hour] = (hourMap[hour] || 0) + (post.likes ?? 0) + (post.comments ?? 0) + (post.shares ?? 0);
    }
    return Object.entries(hourMap).map(([hour, engagement]) => ({ hour: parseInt(hour), engagement }));
  }

  private getBestTimesFromPosts(posts: any[]): Array<{ day: string; hour: number; engagement: number }> {
    const timeMap: Record<string, Record<number, { total: number; count: number }>> = {};
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    for (const post of posts) {
      const date = new Date(post.publishedAt);
      const day = days[date.getDay()];
      const hour = date.getHours();
      if (!timeMap[day]) timeMap[day] = {};
      if (!timeMap[day][hour]) timeMap[day][hour] = { total: 0, count: 0 };
      timeMap[day][hour].total += post.engagementRate ?? 0;
      timeMap[day][hour].count++;
    }

    const result: Array<{ day: string; hour: number; engagement: number }> = [];
    for (const [day, hours] of Object.entries(timeMap)) {
      for (const [hour, data] of Object.entries(hours)) {
        result.push({ day, hour: parseInt(hour), engagement: data.total / data.count });
      }
    }
    return result.sort((a, b) => b.engagement - a.engagement).slice(0, 10);
  }
}
