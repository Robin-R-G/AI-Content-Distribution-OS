class AppConstants {
  static const appName = 'ContentOS';
  static const appTagline = 'Creator Operating System';
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  static const maxLoginAttempts = 5;
  static const lockoutDurationMinutes = 30;
  static const sessionDurationHours = 24;
  static const passwordMinLength = 8;

  static const socialIcons = {
    'instagram': 'assets/icons/instagram.svg',
    'youtube': 'assets/icons/youtube.svg',
    'twitter': 'assets/icons/twitter.svg',
    'linkedin': 'assets/icons/linkedin.svg',
    'tiktok': 'assets/icons/tiktok.svg',
    'facebook': 'assets/icons/facebook.svg',
  };
}
