import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final String themeMode;
  final Locale locale;
  final Map<String, bool> notificationSettings;
  final Map<String, dynamic> additionalSettings;

  const SettingsLoaded({
    required this.themeMode,
    required this.locale,
    required this.notificationSettings,
    this.additionalSettings = const {},
  });

  @override
  List<Object?> get props => [
        themeMode,
        locale,
        notificationSettings,
        additionalSettings,
      ];

  SettingsLoaded copyWith({
    String? themeMode,
    Locale? locale,
    Map<String, bool>? notificationSettings,
    Map<String, dynamic>? additionalSettings,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  // Helper getters
  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String get languageDisplayName {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  String get themeDisplayName {
    switch (themeMode) {
      case 'light':
        return 'Light Mode';
      case 'dark':
        return 'Dark Mode';
      case 'system':
      default:
        return 'System Default';
    }
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SettingsUpdating extends SettingsState {
  final SettingsLoaded currentSettings;
  final String updatingField;

  const SettingsUpdating({
    required this.currentSettings,
    required this.updatingField,
  });

  @override
  List<Object?> get props => [currentSettings, updatingField];
}

class SettingsExported extends SettingsState {
  final String exportPath;
  final SettingsLoaded settings;

  const SettingsExported({
    required this.exportPath,
    required this.settings,
  });

  @override
  List<Object?> get props => [exportPath, settings];
}

class SettingsImported extends SettingsState {
  final SettingsLoaded settings;

  const SettingsImported({required this.settings});

  @override
  List<Object?> get props => [settings];
}
