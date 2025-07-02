import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/settings_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const BlockVestApp());
}

class BlockVestApp extends StatelessWidget {
  const BlockVestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(supabaseClient: di.sl<supabase.SupabaseClient>()),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) =>
              SettingsBloc(settingsService: di.sl<SettingsService>())
                ..add(const LoadSettingsEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          ThemeMode themeMode = ThemeMode.system;
          Locale locale = const Locale('en', '');

          if (settingsState is SettingsLoaded) {
            themeMode = settingsState.themeModeEnum;
            locale = settingsState.locale;
          }

          return MaterialApp.router(
            title: 'BlockVest',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('es', ''), // Spanish
              Locale('fr', ''), // French
            ],
          );
        },
      ),
    );
  }
}
