/// Initialization state management for the CoinTrue app
/// 
/// Tracks the progress of app initialization steps and provides
/// error recovery mechanisms for failed initialization.

import 'dart:io';

enum InitializationStep {
  /// Starting app initialization
  starting,
  
  /// Initializing Flutter binding
  flutterBinding,
  
  /// Configuring HTTPS validation
  httpsValidation,
  
  /// Initializing date formatting
  dateFormatting,
  
  /// Initializing Firebase
  firebase,
  
  /// Initializing SharedPreferences
  preferences,
  
  /// Initialization completed successfully
  completed,
  
  /// Initialization failed
  failed,
}

enum InitializationStatus {
  /// Step is pending execution
  pending,
  
  /// Step is currently running
  running,
  
  /// Step completed successfully
  success,
  
  /// Step failed but app can continue
  failed,
  
  /// Step failed and app cannot continue
  critical,
  
  /// Step was skipped due to previous failure
  skipped,
}

/// Represents the result of an initialization step
class InitializationStepResult {
  final InitializationStep step;
  final InitializationStatus status;
  final String? errorMessage;
  final Exception? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Duration? duration;
  final bool canRetry;
  final bool isCritical;

  const InitializationStepResult({
    required this.step,
    required this.status,
    this.errorMessage,
    this.error,
    this.stackTrace,
    required this.timestamp,
    this.duration,
    this.canRetry = true,
    this.isCritical = false,
  });

  /// Creates a successful step result
  factory InitializationStepResult.success({
    required InitializationStep step,
    required Duration duration,
  }) {
    return InitializationStepResult(
      step: step,
      status: InitializationStatus.success,
      timestamp: DateTime.now(),
      duration: duration,
      canRetry: false,
      isCritical: false,
    );
  }

  /// Creates a failed step result
  factory InitializationStepResult.failed({
    required InitializationStep step,
    required String errorMessage,
    Exception? error,
    StackTrace? stackTrace,
    bool canRetry = true,
    bool isCritical = false,
  }) {
    return InitializationStepResult(
      step: step,
      status: isCritical ? InitializationStatus.critical : InitializationStatus.failed,
      errorMessage: errorMessage,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      canRetry: canRetry,
      isCritical: isCritical,
    );
  }

  /// Creates a skipped step result
  factory InitializationStepResult.skipped({
    required InitializationStep step,
    required String reason,
  }) {
    return InitializationStepResult(
      step: step,
      status: InitializationStatus.skipped,
      errorMessage: reason,
      timestamp: DateTime.now(),
      canRetry: false,
      isCritical: false,
    );
  }
}

/// Manages the overall initialization state of the application
class InitializationState {
  final Map<InitializationStep, InitializationStepResult> _stepResults = {};
  final List<InitializationStep> _executionOrder = [];
  final DateTime _startTime = DateTime.now();
  
  InitializationStep _currentStep = InitializationStep.starting;
  bool _isCompleted = false;
  bool _hasCriticalFailure = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration _stepTimeout = Duration(seconds: 30);

  /// Gets the current initialization step
  InitializationStep get currentStep => _currentStep;

  /// Gets whether initialization is completed
  bool get isCompleted => _isCompleted;

  /// Gets whether there's a critical failure
  bool get hasCriticalFailure => _hasCriticalFailure;

  /// Gets the current retry count
  int get retryCount => _retryCount;

  /// Gets whether retries are available
  bool get canRetry => _retryCount < maxRetries && !_hasCriticalFailure;

  /// Gets the total initialization duration
  Duration get totalDuration => DateTime.now().difference(_startTime);

  /// Gets all step results
  Map<InitializationStep, InitializationStepResult> get stepResults => 
      Map.unmodifiable(_stepResults);

  /// Gets the execution order of steps
  List<InitializationStep> get executionOrder => List.unmodifiable(_executionOrder);

  /// Gets failed steps that can be retried
  List<InitializationStep> get retriableFailedSteps {
    return _stepResults.entries
        .where((entry) => 
            entry.value.status == InitializationStatus.failed && 
            entry.value.canRetry)
        .map((entry) => entry.key)
        .toList();
  }

  /// Gets critical failed steps
  List<InitializationStep> get criticalFailedSteps {
    return _stepResults.entries
        .where((entry) => entry.value.status == InitializationStatus.critical)
        .map((entry) => entry.key)
        .toList();
  }

  /// Gets successful steps
  List<InitializationStep> get successfulSteps {
    return _stepResults.entries
        .where((entry) => entry.value.status == InitializationStatus.success)
        .map((entry) => entry.key)
        .toList();
  }

  /// Starts a new initialization step
  void startStep(InitializationStep step) {
    _currentStep = step;
    if (!_executionOrder.contains(step)) {
      _executionOrder.add(step);
    }
  }

  /// Records the result of an initialization step
  void recordStepResult(InitializationStepResult result) {
    _stepResults[result.step] = result;
    
    if (result.status == InitializationStatus.critical) {
      _hasCriticalFailure = true;
    }
    
    if (result.step == InitializationStep.completed) {
      _isCompleted = true;
    } else if (result.step == InitializationStep.failed) {
      _isCompleted = true;
      _hasCriticalFailure = true;
    }
  }

  /// Increments the retry count
  void incrementRetryCount() {
    _retryCount++;
  }

  /// Resets the state for a retry
  void resetForRetry() {
    _stepResults.clear();
    _executionOrder.clear();
    _currentStep = InitializationStep.starting;
    _isCompleted = false;
    _hasCriticalFailure = false;
  }

  /// Gets a summary of the initialization state
  InitializationSummary getSummary() {
    final successful = successfulSteps.length;
    final failed = _stepResults.values
        .where((result) => result.status == InitializationStatus.failed)
        .length;
    final critical = criticalFailedSteps.length;
    final skipped = _stepResults.values
        .where((result) => result.status == InitializationStatus.skipped)
        .length;

    return InitializationSummary(
      totalSteps: _executionOrder.length,
      successfulSteps: successful,
      failedSteps: failed,
      criticalSteps: critical,
      skippedSteps: skipped,
      totalDuration: totalDuration,
      retryCount: _retryCount,
      isCompleted: _isCompleted,
      hasCriticalFailure: _hasCriticalFailure,
      canRetry: canRetry,
    );
  }

  /// Gets timeout duration for a specific step
  static Duration getStepTimeout(InitializationStep step) {
    // Use shorter timeouts in test environment
    final isTestEnvironment = Platform.environment.containsKey('FLUTTER_TEST') || 
                             Platform.environment.containsKey('UNIT_TEST_MODE');
    
    if (isTestEnvironment) {
      // Much shorter timeouts for tests
      switch (step) {
        case InitializationStep.firebase:
          return const Duration(seconds: 2);
        case InitializationStep.preferences:
          return const Duration(seconds: 1);
        default:
          return const Duration(seconds: 1);
      }
    }
    
    // Normal timeouts for production
    switch (step) {
      case InitializationStep.firebase:
        return const Duration(seconds: 45); // Firebase can take longer
      case InitializationStep.preferences:
        return const Duration(seconds: 15); // Critical step, shorter timeout
      default:
        return _stepTimeout;
    }
  }

  /// Checks if a step is critical for app functionality
  static bool isStepCritical(InitializationStep step) {
    switch (step) {
      case InitializationStep.starting:
      case InitializationStep.flutterBinding:
      case InitializationStep.preferences:
        return true;
      case InitializationStep.httpsValidation:
      case InitializationStep.dateFormatting:
      case InitializationStep.firebase:
        return false;
      case InitializationStep.completed:
      case InitializationStep.failed:
        return false;
    }
  }
}

/// Summary of initialization state
class InitializationSummary {
  final int totalSteps;
  final int successfulSteps;
  final int failedSteps;
  final int criticalSteps;
  final int skippedSteps;
  final Duration totalDuration;
  final int retryCount;
  final bool isCompleted;
  final bool hasCriticalFailure;
  final bool canRetry;

  const InitializationSummary({
    required this.totalSteps,
    required this.successfulSteps,
    required this.failedSteps,
    required this.criticalSteps,
    required this.skippedSteps,
    required this.totalDuration,
    required this.retryCount,
    required this.isCompleted,
    required this.hasCriticalFailure,
    required this.canRetry,
  });

  /// Gets the success rate as a percentage
  double get successRate {
    if (totalSteps == 0) return 0.0;
    return (successfulSteps / totalSteps) * 100;
  }

  /// Gets whether initialization was mostly successful
  bool get isMostlySuccessful => successRate >= 80.0 && criticalSteps == 0;

  @override
  String toString() {
    return 'InitializationSummary('
        'steps: $successfulSteps/$totalSteps successful, '
        'failed: $failedSteps, critical: $criticalSteps, '
        'duration: ${totalDuration.inMilliseconds}ms, '
        'retries: $retryCount'
        ')';
  }
}