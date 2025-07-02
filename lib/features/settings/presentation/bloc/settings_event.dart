import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class ChangeThemeEvent extends SettingsEvent {
  final String themeMode; // 'light', 'dark', 'system'

  const ChangeThemeEvent({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class ChangeLanguageEvent extends SettingsEvent {
  final String languageCode;
  final String countryCode;

  const ChangeLanguageEvent({
    required this.languageCode,
    this.countryCode = '',
  });

  @override
  List<Object?> get props => [languageCode, countryCode];
}

class UpdateNotificationSettingsEvent extends SettingsEvent {
  final Map<String, bool> notificationSettings;

  const UpdateNotificationSettingsEvent({required this.notificationSettings});

  @override
  List<Object?> get props => [notificationSettings];
}

class ToggleNotificationEvent extends SettingsEvent {
  final String notificationType;
  final bool enabled;

  const ToggleNotificationEvent({
    required this.notificationType,
    required this.enabled,
  });

  @override
  List<Object?> get props => [notificationType, enabled];
}

class ResetSettingsEvent extends SettingsEvent {
  const ResetSettingsEvent();
}

class ExportSettingsEvent extends SettingsEvent {
  const ExportSettingsEvent();
}

class ImportSettingsEvent extends SettingsEvent {
  final Map<String, dynamic> settingsData;

  const ImportSettingsEvent({required this.settingsData});

  @override
  List<Object?> get props => [settingsData];
}
