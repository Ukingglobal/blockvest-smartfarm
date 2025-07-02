import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/settings_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;

  SettingsBloc({required SettingsService settingsService})
      : _settingsService = settingsService,
        super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<UpdateNotificationSettingsEvent>(_onUpdateNotificationSettings);
    on<ToggleNotificationEvent>(_onToggleNotification);
    on<ResetSettingsEvent>(_onResetSettings);
    on<ExportSettingsEvent>(_onExportSettings);
    on<ImportSettingsEvent>(_onImportSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      final themeMode = await _settingsService.getThemeMode();
      final locale = await _settingsService.getLocale();
      final notificationSettings = await _settingsService.getNotificationSettings();
      final additionalSettings = await _settingsService.getAdditionalSettings();

      emit(SettingsLoaded(
        themeMode: themeMode,
        locale: locale,
        notificationSettings: notificationSettings,
        additionalSettings: additionalSettings,
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(SettingsUpdating(
          currentSettings: currentState,
          updatingField: 'theme',
        ));

        await _settingsService.setThemeMode(event.themeMode);

        emit(currentState.copyWith(themeMode: event.themeMode));
      }
    } catch (e) {
      emit(SettingsError(message: 'Failed to change theme: ${e.toString()}'));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(SettingsUpdating(
          currentSettings: currentState,
          updatingField: 'language',
        ));

        await _settingsService.setLocale(event.languageCode, event.countryCode);

        final newLocale = Locale(event.languageCode, event.countryCode);
        emit(currentState.copyWith(locale: newLocale));
      }
    } catch (e) {
      emit(SettingsError(message: 'Failed to change language: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(SettingsUpdating(
          currentSettings: currentState,
          updatingField: 'notifications',
        ));

        await _settingsService.setNotificationSettings(event.notificationSettings);

        emit(currentState.copyWith(
          notificationSettings: event.notificationSettings,
        ));
      }
    } catch (e) {
      emit(SettingsError(
        message: 'Failed to update notification settings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleNotification(
    ToggleNotificationEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        final updatedSettings = Map<String, bool>.from(currentState.notificationSettings);
        updatedSettings[event.notificationType] = event.enabled;

        emit(SettingsUpdating(
          currentSettings: currentState,
          updatingField: 'notification_${event.notificationType}',
        ));

        await _settingsService.updateNotificationSetting(
          event.notificationType,
          event.enabled,
        );

        emit(currentState.copyWith(notificationSettings: updatedSettings));
      }
    } catch (e) {
      emit(SettingsError(
        message: 'Failed to toggle notification: ${e.toString()}',
      ));
    }
  }

  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      await _settingsService.resetToDefaults();

      // Reload settings after reset
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(message: 'Failed to reset settings: ${e.toString()}'));
    }
  }

  Future<void> _onExportSettings(
    ExportSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        final exportData = await _settingsService.exportSettings();
        
        // For now, we'll just emit the current state with export data
        // In a real app, you might save to file or share
        emit(SettingsExported(
          exportPath: 'settings_export.json',
          settings: currentState,
        ));
        
        // Return to loaded state
        emit(currentState);
      }
    } catch (e) {
      emit(SettingsError(message: 'Failed to export settings: ${e.toString()}'));
    }
  }

  Future<void> _onImportSettings(
    ImportSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Convert the settings data to JSON string for import
      final settingsJson = event.settingsData.toString();
      await _settingsService.importSettings(settingsJson);

      // Reload settings after import
      add(const LoadSettingsEvent());
    } catch (e) {
      emit(SettingsError(message: 'Failed to import settings: ${e.toString()}'));
    }
  }
}
