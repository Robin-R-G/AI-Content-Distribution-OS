import { z } from 'zod';

export const emailSchema = z
  .string()
  .trim()
  .toLowerCase()
  .email('Please enter a valid email address')
  .max(255, 'Email is too long');

export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(128, 'Password is too long')
  .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
  .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
  .regex(/[0-9]/, 'Password must contain at least one number')
  .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character');

export const nameSchema = z
  .string()
  .trim()
  .min(1, 'Name is required')
  .max(100, 'Name is too long')
  .regex(/^[a-zA-Z\s'-]+$/, 'Name contains invalid characters');

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Password is required').max(128),
});

export const registerSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
  firstName: nameSchema,
  lastName: nameSchema,
});

export const mfaCodeSchema = z
  .string()
  .length(6, 'MFA code must be 6 digits')
  .regex(/^\d{6}$/, 'MFA code must be numeric');

export const passwordResetSchema = z.object({
  email: emailSchema,
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type MFAInput = z.infer<typeof mfaCodeSchema>;

export function validateInput<T>(schema: z.ZodSchema<T>, data: unknown): {
  success: true;
  data: T;
} | {
  success: false;
  errors: string[];
} {
  const result = schema.safeParse(data);
  if (result.success) {
    return { success: true, data: result.data };
  }
  return {
    success: false,
    errors: result.error.errors.map((e) => e.message),
  };
}

export function sanitizeInput(input: string): string {
  return input
    .trim()
    .replace(/[<>]/g, '')
    .replace(/javascript:/gi, '')
    .replace(/on\w+=/gi, '')
    .substring(0, 1000);
}
