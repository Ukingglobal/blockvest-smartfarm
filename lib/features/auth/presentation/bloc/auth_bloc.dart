import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [email, password, firstName, lastName];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthStatusChanged extends AuthEvent {
  final supabase.User? user;

  const AuthStatusChanged({this.user});

  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final supabase.SupabaseClient _supabaseClient;

  AuthBloc({required supabase.SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient,
      super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);

    // Listen to auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      add(AuthStatusChanged(user: data.session?.user));
    });
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user == null) {
        emit(const AuthError(message: 'Sign in failed'));
        return;
      }

      final user = User(
        id: response.user!.id,
        email: response.user!.email!,
        createdAt: DateTime.parse(response.user!.createdAt),
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {'first_name': event.firstName, 'last_name': event.lastName},
      );

      if (response.user == null) {
        emit(const AuthError(message: 'Sign up failed'));
        return;
      }

      final user = User(
        id: response.user!.id,
        email: response.user!.email!,
        firstName: event.firstName,
        lastName: event.lastName,
        createdAt: DateTime.parse(response.user!.createdAt),
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _supabaseClient.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      final user = User(
        id: event.user!.id,
        email: event.user!.email!,
        firstName: event.user!.userMetadata?['first_name'],
        lastName: event.user!.userMetadata?['last_name'],
        createdAt: DateTime.parse(event.user!.createdAt),
      );
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
