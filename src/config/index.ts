import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  HOST: z.string().default('localhost'),

  DATABASE_URL: z.string(),
  DATABASE_POOL_MIN: z.coerce.number().default(2),
  DATABASE_POOL_MAX: z.coerce.number().default(10),

  REDIS_URL: z.string().default('redis://localhost:6379'),
  REDIS_PASSWORD: z.string().optional(),

  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),
  SESSION_SECRET: z.string().min(32),

  OPENAI_API_KEY: z.string().optional(),
  ANTHROPIC_API_KEY: z.string().optional(),
  GOOGLE_AI_API_KEY: z.string().optional(),
  AZURE_OPENAI_API_KEY: z.string().optional(),
  AZURE_OPENAI_ENDPOINT: z.string().optional(),
  GROQ_API_KEY: z.string().optional(),
  REPLICATE_API_TOKEN: z.string().optional(),

  STRIPE_SECRET_KEY: z.string().optional(),
  STRIPE_WEBHOOK_SECRET: z.string().optional(),

  SENDGRID_API_KEY: z.string().optional(),
  FCM_SERVER_KEY: z.string().optional(),

  S3_BUCKET: z.string().optional(),
  S3_REGION: z.string().optional(),
  S3_ACCESS_KEY: z.string().optional(),
  S3_SECRET_KEY: z.string().optional(),

  APP_URL: z.string().url().default('http://localhost:3000'),
  API_URL: z.string().url().default('http://localhost:3000/api'),

  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  CORS_ORIGINS: z.string().default('http://localhost:3000'),

  RATE_LIMIT_WINDOW_MS: z.coerce.number().default(60000),
  RATE_LIMIT_MAX: z.coerce.number().default(100),
});

type Env = z.infer<typeof envSchema>;

let _config: Env | null = null;

export function getConfig(): Env {
  if (!_config) {
    _config = envSchema.parse(process.env);
  }
  return _config;
}

export const databaseConfig = () => {
  const cfg = getConfig();
  return {
    url: cfg.DATABASE_URL,
    pool: { min: cfg.DATABASE_POOL_MIN, max: cfg.DATABASE_POOL_MAX },
  };
};

export const redisConfig = () => {
  const cfg = getConfig();
  return {
    url: cfg.REDIS_URL,
    password: cfg.REDIS_PASSWORD,
  };
};

export const aiProviderConfig = () => {
  const cfg = getConfig();
  return {
    openai: { apiKey: cfg.OPENAI_API_KEY },
    anthropic: { apiKey: cfg.ANTHROPIC_API_KEY },
    google: { apiKey: cfg.GOOGLE_AI_API_KEY },
    azure: { apiKey: cfg.AZURE_OPENAI_API_KEY, endpoint: cfg.AZURE_OPENAI_ENDPOINT },
    groq: { apiKey: cfg.GROQ_API_KEY },
    replicate: { token: cfg.REPLICATE_API_TOKEN },
  };
};

export const billingConfig = () => {
  const cfg = getConfig();
  return {
    stripeSecretKey: cfg.STRIPE_SECRET_KEY,
    stripeWebhookSecret: cfg.STRIPE_WEBHOOK_SECRET,
  };
};

export const emailConfig = () => {
  const cfg = getConfig();
  return {
    sendgridApiKey: cfg.SENDGRID_API_KEY,
    fromEmail: 'noreply@socialmediaai.com',
  };
};

export const storageConfig = () => {
  const cfg = getConfig();
  return {
    bucket: cfg.S3_BUCKET,
    region: cfg.S3_REGION,
    accessKey: cfg.S3_ACCESS_KEY,
    secretKey: cfg.S3_SECRET_KEY,
  };
};

export const corsConfig = () => {
  const cfg = getConfig();
  return {
    origins: cfg.CORS_ORIGINS.split(','),
  };
};

export const rateLimitConfig = () => {
  const cfg = getConfig();
  return {
    windowMs: cfg.RATE_LIMIT_WINDOW_MS,
    max: cfg.RATE_LIMIT_MAX,
  };
};
