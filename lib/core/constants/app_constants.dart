class AppConstants {
  // App Information
  static const String appName = 'BlockVest';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Agricultural Investment Platform';

  // Supabase Configuration - BlockVest SmartFarm Project
  static const String supabaseUrl = 'https://jeyhruxdhnmagknfcqng.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpleWhydXhkaG5tYWdrbmZjcW5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0MTA3MTUsImV4cCI6MjA2Njk4NjcxNX0.X7hBDjCCBKMuM97105VBcaVtBbrEwdnmz7n9ATcPNC0';

  // Blockchain Configuration - Supra Network
  static const String supraBlocchainRPC = 'https://rpc-testnet.supra.com';
  static const int supraChainId = 6;

  // Token Information
  static const String tokenName = 'BLOCKVEST';
  static const String tokenSymbol = '\$BLOCKVEST';

  // Investment Limits
  static const double minInvestmentAmount = 100.0;
  static const double maxInvestmentAmount = 100000.0;

  // Staking Configuration
  static const double stakingAPY = 12.5; // 12.5% APY
  static const int minStakingDays = 30;
  static const int maxStakingDays = 365;

  // KYC Verification
  static const List<String> requiredKycDocuments = [
    'National ID',
    'Passport',
    'Driver\'s License',
  ];

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'es', 'fr'];
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
  };

  // Nigerian Agricultural Regions
  static const List<String> nigerianStates = [
    'Lagos',
    'Kano',
    'Kaduna',
    'Oyo',
    'Rivers',
    'Bayelsa',
    'Akwa Ibom',
    'Imo',
    'Delta',
    'Edo',
    'Plateau',
    'Cross River',
    'Osun',
    'Ondo',
    'Ogun',
    'Kwara',
    'Benue',
    'Niger',
    'Kebbi',
    'Sokoto',
  ];

  // Crop Types
  static const List<String> cropTypes = [
    'Rice',
    'Maize',
    'Cassava',
    'Yam',
    'Cocoa',
    'Palm Oil',
    'Plantain',
    'Beans',
    'Millet',
    'Sorghum',
    'Groundnut',
    'Cotton',
  ];

  // Investment Duration Options (in months)
  static const List<int> investmentDurations = [6, 12, 18, 24, 36];

  // ROI Ranges by crop type (annual percentage)
  static const Map<String, Map<String, double>> cropROIRanges = {
    'Rice': {'min': 15.0, 'max': 25.0},
    'Maize': {'min': 18.0, 'max': 28.0},
    'Cassava': {'min': 12.0, 'max': 20.0},
    'Yam': {'min': 20.0, 'max': 35.0},
    'Cocoa': {'min': 25.0, 'max': 40.0},
    'Palm Oil': {'min': 30.0, 'max': 45.0},
    'Plantain': {'min': 16.0, 'max': 24.0},
    'Beans': {'min': 14.0, 'max': 22.0},
    'Millet': {'min': 13.0, 'max': 21.0},
    'Sorghum': {'min': 15.0, 'max': 23.0},
    'Groundnut': {'min': 17.0, 'max': 26.0},
    'Cotton': {'min': 22.0, 'max': 32.0},
  };
}
