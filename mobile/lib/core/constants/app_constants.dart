class AppConstants {
  static const appName = 'ContentOS';
  static const appTagline = 'Creator Operating System';
  static const appVersion = '1.0.0';

  // Supabase
  static const supabaseUrl = 'https://wycctemdqhkeensqpcnn.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5Y2N0ZW1kcWhrZWVuc3FwY25uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4Mzc4OTUsImV4cCI6MjA5ODQxMzg5NX0.63uPngdck5h5xqqliiftDIfKM_okTX9q1n9Kth9TRX8';

  // Security
  static const maxLoginAttempts = 5;
  static const lockoutDurationMinutes = 30;
  static const sessionDurationHours = 24;
  static const passwordMinLength = 8;
  static const passwordMaxLength = 128;
  static const emailMaxLength = 254;

  // Social Icons
  static const socialIcons = {
    'instagram': 'assets/icons/instagram.svg',
    'youtube': 'assets/icons/youtube.svg',
    'twitter': 'assets/icons/twitter.svg',
    'linkedin': 'assets/icons/linkedin.svg',
    'tiktok': 'assets/icons/tiktok.svg',
    'facebook': 'assets/icons/facebook.svg',
  };
}
