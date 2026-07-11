import 'dart:async';
import 'package:grpc/grpc.dart' as grpc;
import 'package:web_admin/providers/session_recovery.dart';

/// Intercepts gRPC calls and detects 401 Unauthenticated errors.
/// This is crucial for the BFF mode where Envoy might return 401
/// if the session cookie is invalid or expired.
class UnauthenticatedInterceptor extends grpc.ClientInterceptor {
  @override
  grpc.ResponseFuture<R> interceptUnary<Q, R>(
    grpc.ClientMethod<Q, R> method,
    Q request,
    grpc.CallOptions options,
    grpc.ClientUnaryInvoker<Q, R> invoker,
  ) {
    final guardedOptions = options.mergedWith(
      grpc.CallOptions(
        providers: [
          SessionRecoveryBinding.instance.ensureSessionForRequest,
        ],
      ),
    );

    final completer = Completer<R>();

    void executeRequest() {
      final response = invoker(method, request, guardedOptions);
      response.then((val) {
        if (!completer.isCompleted) {
          completer.complete(val);
        }
      }).catchError((Object e, StackTrace st) {
        if (SessionRecoveryBinding.instance.isUnauthenticated(e)) {
          // Attempt recovery
          SessionRecoveryBinding.instance
              .recoverFromUnauthenticated()
              .then((success) {
            if (success) {
              // Retry once
              invoker(method, request, guardedOptions).then((val) {
                if (!completer.isCompleted) {
                  completer.complete(val);
                }
              }).catchError((Object e2, StackTrace st2) {
                if (!completer.isCompleted) {
                  completer.completeError(e2, st2);
                }
              });
            } else {
              if (!completer.isCompleted) {
                completer.completeError(e, st);
              }
            }
          }).catchError((Object e3, StackTrace st3) {
            if (!completer.isCompleted) {
              completer.completeError(e3, st3);
            }
          });
        } else {
          if (!completer.isCompleted) {
            completer.completeError(e, st);
          }
        }
      });
    }

    executeRequest();

    return _ResponseFutureFromFuture(completer.future);
  }

  @override
  grpc.ResponseStream<R> interceptStreaming<Q, R>(
    grpc.ClientMethod<Q, R> method,
    Stream<Q> requests,
    grpc.CallOptions options,
    grpc.ClientStreamingInvoker<Q, R> invoker,
  ) {
    final response = invoker(method, requests, options);

    // For streams, we listen to the first error if it happens early
    // or handle it via the stream subscription in the UI.
    return response;
  }
}

class _ResponseFutureFromFuture<R> implements grpc.ResponseFuture<R> {
  final Future<R> _future;

  _ResponseFutureFromFuture(this._future);

  @override
  Future<Map<String, String>> get headers => Future.value({});

  @override
  Future<Map<String, String>> get trailers => Future.value({});

  @override
  Future<R> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<S> then<S>(FutureOr<S> Function(R value) onValue,
          {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<R> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Stream<R> asStream() => _future.asStream();

  @override
  Future<R> timeout(Duration timeLimit, {FutureOr<R> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<void> cancel() => Future.value();
}
