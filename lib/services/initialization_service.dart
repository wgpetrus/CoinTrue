import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../core/config/firebase_options.dart';
import '../models/initialization_state.dart';
import '../services/shared_preferences_service.dart';
import '../utils/https_validator.dart';
import '../utils/error_handler.dart';

/// Service responsible for managing the app initialization process
/// 
/// Provides progressive loading with error recovery, timeout handling,
/// and detailed logging of initialization steps.
class InitializationService {
  static InitializationService? _instance;
  static InitializationService get instance => _instance ??= InitializationService._();
  
  InitializationService._();

  final InitializationState _state = InitializationState();
  final StreamController<InitializationState> _stateController = 
      StreamController<InitializationState>.broadcast();

  /// Stream of initialization state changes
  Stream<InitializationState> get stateStream => _stateController.stream;

  /// Current initialization state
  InitializationState get currentState => _state;

  /// Initializes the application with progressive loading and error recovery
  Future<InitializationResult> initialize() async {
    try {
      _logInitializationStart();
      
      // Execute initialization steps in order
      await _executeInitializationSteps();
      
      // Check final state and return result
      return _buildFinalResult();
      
    } catch (error, stackTrace) {
      _logCriticalError('Unexpected error during initialization', error, stackTrace);
      
      final result = InitializationStepResult.failed(
        step: InitializationStep.failed,
        errorMessage: 'Critical initialization failure',
        error: error is Exception ? error : Exception(error.toString()),
        stackTrace: stackTrace,
        isCritical: true,
        canRetry: false,
      );
      
      _state.recordStepResult(result);
      _notifyStateChange();
      
      return InitializationResult.failure(
        summary: _state.getSummary(),
        criticalError: 'Application failed to initialize: ${error.toString()}',
      );
    }
  }

  /// Retries failed initialization steps
  Future<InitializationResult> retry() async {
    if (!_state.canRetry) {
      return InitializationResult.failure(
        summary: _state.getSummary(),
        criticalError: 'No more retries available or critical failure occurred',
      );
    }

    _logRetryAttempt();
    _state.incrementRetryCount();
    _state.resetForRetry();
    
    return await initialize();
  }

  /// Executes all initialization steps in sequence
  Future<void> _executeInitializationSteps() async {
    // Step 1: Flutter Binding
    await _executeStep(
      InitializationStep.flutterBinding,
      _initializeFlutterBinding,
    );

    // Step 2: HTTPS Validation (non-critical)
    await _executeStep(
      InitializationStep.httpsValidation,
      _initializeHttpsValidation,
    );

    // Step 3: Date Formatting (non-critical)
    await _executeStep(
      InitializationStep.dateFormatting,
      _initializeDateFormatting,
    );

    // Step 4: Firebase (non-critical)
    await _executeStep(
      InitializationStep.firebase,
      _initializeFirebase,
    );

    // Step 5: SharedPreferences (critical)
    await _executeStep(
      InitializationStep.preferences,
      _initializePreferences,
    );

    // Mark as completed if we got this far
    if (!_state.hasCriticalFailure) {
      final result = InitializationStepResult.success(
        step: InitializationStep.completed,
        duration: _state.totalDuration,
      );
      _state.recordStepResult(result);
    }
  }

  /// Executes a single initialization step with timeout and error handling
  Future<void> _executeStep(
    InitializationStep step,
    Future<void> Function() stepFunction,
  ) async {
    // Skip if we have a critical failure
    if (_state.hasCriticalFailure) {
      final result = InitializationStepResult.skipped(
        step: step,
        reason: 'Skipped due to previous critical failure',
      );
      _state.recordStepResult(result);
      _notifyStateChange();
      return;
    }

    _state.startStep(step);
    _notifyStateChange();
    
    final stopwatch = Stopwatch()..start();
    final timeout = InitializationState.getStepTimeout(step);
    final isCritical = InitializationState.isStepCritical(step);

    try {
      _logStepStart(step);
      
      // Execute step with timeout
      await stepFunction().timeout(timeout);
      
      stopwatch.stop();
      
      final result = InitializationStepResult.success(
        step: step,
        duration: stopwatch.elapsed,
      );
      
      _state.recordStepResult(result);
      _logStepSuccess(step, stopwatch.elapsed);
      
    } catch (error, stackTrace) {
      stopwatch.stop();
      
      final isTimeoutError = error is TimeoutException;
      final errorMessage = isTimeoutError 
          ? 'Step timed out after ${timeout.inSeconds} seconds'
          : error.toString();
      
      final result = InitializationStepResult.failed(
        step: step,
        errorMessage: errorMessage,
        error: error is Exception ? error : Exception(error.toString()),
        stackTrace: stackTrace,
        canRetry: !isTimeoutError && !isCritical,
        isCritical: isCritical,
      );
      
      _state.recordStepResult(result);
      _logStepFailure(step, error, stackTrace, stopwatch.elapsed);
      
      // If this is a critical step, we cannot continue
      if (isCritical) {
        _logCriticalStepFailure(step, error);
      }
    }
    
    _notifyStateChange();
  }

  /// Initializes Flutter binding
  Future<void> _initializeFlutterBinding() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  /// Initializes HTTPS validation
  Future<void> _initializeHttpsValidation() async {
    HttpsValidator.configureHttpClient();
  }

  /// Initializes date formatting
  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('pt_BR', null);
  }

  /// Initializes Firebase
  Future<void> _initializeFirebase() async {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    // If already initialized, just continue - this is normal during hot reload
  }

  /// Initializes SharedPreferences
  Future<void> _initializePreferences() async {
    await SharedPreferencesService.getInstance();
  }

  /// Builds the final initialization result
  InitializationResult _buildFinalResult() {
    final summary = _state.getSummary();
    
    if (_state.hasCriticalFailure) {
      final criticalSteps = _state.criticalFailedSteps;
      final criticalErrors = criticalSteps
          .map((step) => _state.stepResults[step]?.errorMessage ?? 'Unknown error')
          .join('; ');
      
      return InitializationResult.failure(
        summary: summary,
        criticalError: 'Critical initialization failures: $criticalErrors',
      );
    }
    
    if (summary.isMostlySuccessful) {
      return InitializationResult.success(
        summary: summary,
        firebaseAvailable: _state.stepResults[InitializationStep.firebase]?.status == 
            InitializationStatus.success,
      );
    }
    
    return InitializationResult.partialSuccess(
      summary: summary,
      firebaseAvailable: _state.stepResults[InitializationStep.firebase]?.status == 
          InitializationStatus.success,
    );
  }

  /// Notifies listeners of state changes
  void _notifyStateChange() {
    _stateController.add(_state);
  }

  /// Disposes resources
  void dispose() {
    _stateController.close();
  }

  // ============================================================================
  // LOGGING METHODS
  // ============================================================================

  void _logInitializationStart() {
    developer.log(
      'Starting app initialization (attempt ${_state.retryCount + 1})',
      name: 'InitializationService',
      level: 800,
    );
    
    if (kDebugMode) {
      debugPrint('🚀 Starting app initialization (attempt ${_state.retryCount + 1})');
    }
  }

  void _logRetryAttempt() {
    developer.log(
      'Retrying initialization (attempt ${_state.retryCount + 1}/${InitializationState.maxRetries})',
      name: 'InitializationService',
      level: 900,
    );
    
    if (kDebugMode) {
      debugPrint('🔄 Retrying initialization (attempt ${_state.retryCount + 1})');
    }
  }

  void _logStepStart(InitializationStep step) {
    developer.log(
      'Starting step: ${step.name}',
      name: 'InitializationService',
      level: 800,
    );
    
    if (kDebugMode) {
      debugPrint('⏳ Starting step: ${step.name}');
    }
  }

  void _logStepSuccess(InitializationStep step, Duration duration) {
    developer.log(
      'Step completed: ${step.name} (${duration.inMilliseconds}ms)',
      name: 'InitializationService',
      level: 800,
    );
    
    if (kDebugMode) {
      debugPrint('✅ Step completed: ${step.name} (${duration.inMilliseconds}ms)');
    }
  }

  void _logStepFailure(
    InitializationStep step, 
    dynamic error, 
    StackTrace? stackTrace,
    Duration duration,
  ) {
    final isCritical = InitializationState.isStepCritical(step);
    
    developer.log(
      '${isCritical ? 'CRITICAL' : 'NON-CRITICAL'} step failed: ${step.name} - $error (${duration.inMilliseconds}ms)',
      name: 'InitializationService',
      level: isCritical ? 1000 : 900,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (kDebugMode) {
      final icon = isCritical ? '🚨' : '⚠️';
      debugPrint('$icon Step failed: ${step.name} - $error (${duration.inMilliseconds}ms)');
      if (stackTrace != null) {
        debugPrint('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      }
    }
  }

  void _logCriticalStepFailure(InitializationStep step, dynamic error) {
    developer.log(
      'CRITICAL FAILURE: Cannot continue initialization due to ${step.name} failure: $error',
      name: 'InitializationService',
      level: 1200,
      error: error,
    );
    
    if (kDebugMode) {
      debugPrint('🛑 CRITICAL FAILURE: Cannot continue due to ${step.name} failure');
    }
  }

  void _logCriticalError(String context, dynamic error, StackTrace stackTrace) {
    developer.log(
      'CRITICAL ERROR during $context: $error',
      name: 'InitializationService',
      level: 1200,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (kDebugMode) {
      debugPrint('🚨 CRITICAL ERROR during $context: $error');
    }
  }
}

/// Result of the initialization process
class InitializationResult {
  final bool isSuccess;
  final bool isPartialSuccess;
  final InitializationSummary summary;
  final String? criticalError;
  final bool firebaseAvailable;

  const InitializationResult._({
    required this.isSuccess,
    required this.isPartialSuccess,
    required this.summary,
    this.criticalError,
    required this.firebaseAvailable,
  });

  /// Creates a successful initialization result
  factory InitializationResult.success({
    required InitializationSummary summary,
    required bool firebaseAvailable,
  }) {
    return InitializationResult._(
      isSuccess: true,
      isPartialSuccess: false,
      summary: summary,
      firebaseAvailable: firebaseAvailable,
    );
  }

  /// Creates a partial success initialization result
  factory InitializationResult.partialSuccess({
    required InitializationSummary summary,
    required bool firebaseAvailable,
  }) {
    return InitializationResult._(
      isSuccess: false,
      isPartialSuccess: true,
      summary: summary,
      firebaseAvailable: firebaseAvailable,
    );
  }

  /// Creates a failed initialization result
  factory InitializationResult.failure({
    required InitializationSummary summary,
    required String criticalError,
  }) {
    return InitializationResult._(
      isSuccess: false,
      isPartialSuccess: false,
      summary: summary,
      criticalError: criticalError,
      firebaseAvailable: false,
    );
  }

  /// Gets whether the app can continue running
  bool get canContinue => isSuccess || isPartialSuccess;

  /// Gets a user-friendly status message
  String get statusMessage {
    if (isSuccess) {
      return 'App initialized successfully';
    } else if (isPartialSuccess) {
      return 'App initialized with some limitations';
    } else {
      return criticalError ?? 'App failed to initialize';
    }
  }

  @override
  String toString() {
    return 'InitializationResult('
        'success: $isSuccess, '
        'partial: $isPartialSuccess, '
        'firebase: $firebaseAvailable, '
        'summary: $summary'
        ')';
  }
}