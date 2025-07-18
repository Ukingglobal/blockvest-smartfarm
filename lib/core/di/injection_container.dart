import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import '../constants/app_constants.dart';
import '../services/web3_service.dart';
import '../services/portfolio_service.dart';
import '../services/smart_contract_service.dart';
import '../services/biometric_service.dart';
import '../services/kyc_service.dart';
import '../services/mfa_service.dart';
import '../services/settings_service.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/marketplace/domain/repositories/project_repository.dart';
import '../../features/marketplace/data/repositories/project_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  sl.registerLazySingleton(() => Supabase.instance.client);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => Web3Service());
  sl.registerLazySingleton(() => PortfolioService());
  sl.registerLazySingleton(() => SmartContractService());

  // Security Services
  sl.registerLazySingleton(() => BiometricService());
  sl.registerLazySingleton(() => KYCService());
  sl.registerLazySingleton(() => MFAService());

  // Settings Service
  sl.registerLazySingleton(() => SettingsService()..initialize());

  // Data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(web3Service: sl()),
  );

  // Repositories
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl());

  // Use cases
  // TODO: Register use cases when needed

  // BLoCs
  // TODO: Register BLoCs when needed
}
