export interface DateRange {
  start: Date | string;
  end: Date | string;
}

export interface AnalyticsFilter {
  dateRange: DateRange;
  platforms?: string[];
  accountIds?: string[];
  postIds?: string[];
  contentTypes?: string[];
}

export interface PlatformMetrics {
  platform: string;
  followers: number;
  followersGrowth: number;
  followersGrowthRate: number;
  impressions: number;
  reach: number;
  engagement: number;
  engagementRate: number;
  posts: number;
  topPost?: PostMetrics;
}

export interface AccountMetrics {
  accountId: string;
  platform: string;
  username: string;
  displayName: string;
  avatar?: string;
  followers: number;
  following: number;
  posts: number;
  engagementRate: number;
  impressions: number;
  reach: number;
  profileViews: number;
  websiteClicks: number;
}

export interface PostMetrics {
  postId: string;
  platform: string;
  accountId: string;
  content: string;
  mediaType?: string;
  postedAt: Date;
  impressions: number;
  reach: number;
  likes: number;
  comments: number;
  shares: number;
  saves: number;
  clicks: number;
  engagementRate: number;
  sentiment?: { positive: number; neutral: number; negative: number };
}

export interface AudienceDemographics {
  age: Array<{ range: string; percentage: number }>;
  gender: Array<{ type: string; percentage: number }>;
  location: Array<{ country: string; percentage: number }>;
  language: Array<{ language: string; percentage: number }>;
  interests: Array<{ topic: string; percentage: number }>;
  activeHours: Array<{ hour: number; percentage: number }>;
}

export interface EngagementMetrics {
  totalEngagement: number;
  engagementRate: number;
  avgLikes: number;
  avgComments: number;
  avgShares: number;
  avgSaves: number;
  topContent: PostMetrics[];
  engagementByDay: Array<{ day: string; engagement: number }>;
  engagementByHour: Array<{ hour: number; engagement: number }>;
}

export interface GrowthMetrics {
  followersGrowth: number;
  followersGrowthRate: number;
  newFollowers: number;
  unfollowers: number;
  netGrowth: number;
  projectedFollowers: number;
  growthByDay: Array<{ date: string; followers: number; growth: number }>;
}

export interface ContentPerformance {
  topPosts: PostMetrics[];
  avgPerformance: { impressions: number; engagement: number; engagementRate: number };
  contentTypeBreakdown: Array<{ type: string; count: number; avgEngagement: number }>;
  hashtagPerformance: Array<{ tag: string; posts: number; avgEngagement: number }>;
  bestPerformingTimes: Array<{ day: string; hour: number; engagement: number }>;
}

export interface AnalyticsSnapshot {
  id: string;
  workspaceId: string;
  dateRange: DateRange;
  overview: {
    totalFollowers: number;
    followersGrowth: number;
    totalImpressions: number;
    totalReach: number;
    totalEngagement: number;
    avgEngagementRate: number;
    totalPosts: number;
  };
  platforms: PlatformMetrics[];
  accounts: AccountMetrics[];
  audience?: AudienceDemographics;
  engagement?: EngagementMetrics;
  growth?: GrowthMetrics;
  contentPerformance?: ContentPerformance;
  generatedAt: Date;
}

export interface AnalyticsGoal {
  id: string;
  workspaceId: string;
  name: string;
  metric: string;
  targetValue: number;
  currentValue: number;
  deadline: Date;
  status: 'on_track' | 'at_risk' | 'behind' | 'achieved';
}
