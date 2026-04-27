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
    final response = invoker(method, request, guardedOptions);

    unawaited(
      response.catchError((Object e, StackTrace st) {
        SessionRecoveryBinding.instance.noteIfUnauthenticated(e);
        return Future<R>.error(e, st);
      }),
    );

    return response;
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
