import 'package:entitlements_weebi/entitlements_weebi.dart';
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:protos_weebi/grpc.dart' show GrpcError;

export 'package:entitlements_weebi/entitlements_weebi.dart'
    show kFreemiumFullDumpQuotaExceeded, FreemiumDumpQuotaError;

/// True when [error] is the freemium full-dump quota denial.
bool isFreemiumDumpQuotaExceeded(Object error) {
  if (error is! GrpcError) {
    return FreemiumDumpQuotaError.tryParse(error) != null;
  }
  if (error.code != grpc.StatusCode.resourceExhausted) return false;
  return FreemiumDumpQuotaError.tryParse(error) != null;
}

/// Static hook so gRPC interceptors can signal the UI without a [BuildContext].
class FreemiumDumpQuotaBinding {
  FreemiumDumpQuotaBinding._();
  static final instance = FreemiumDumpQuotaBinding._();

  FreemiumDumpQuotaNotifier? _notifier;

  void attach(FreemiumDumpQuotaNotifier notifier) {
    _notifier = notifier;
  }

  void noteIfExceeded(Object error) {
    _notifier?.noteIfExceeded(error);
  }

  void clear() {
    _notifier?.clear();
  }
}

/// Drives a non-blocking banner / snackbar when a full dump is quota-exceeded.
class FreemiumDumpQuotaNotifier extends ChangeNotifier {
  FreemiumDumpQuotaError? _last;

  FreemiumDumpQuotaError? get lastError => _last;

  bool get hasError => _last != null;

  void noteIfExceeded(Object error) {
    final parsed = FreemiumDumpQuotaError.tryParse(error);
    if (parsed == null) return;
    _last = parsed;
    notifyListeners();
  }

  void clear() {
    if (_last == null) return;
    _last = null;
    notifyListeners();
  }
}
