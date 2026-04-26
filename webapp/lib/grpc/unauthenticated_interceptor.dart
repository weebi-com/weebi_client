import 'dart:async';
import 'package:grpc/grpc.dart' as grpc;
import 'package:flutter/foundation.dart';

/// Intercepts gRPC calls and detects 401 Unauthenticated errors.
/// This is crucial for the BFF mode where Envoy might return 401 
/// if the session cookie is invalid or expired.
class UnauthenticatedInterceptor extends grpc.ClientInterceptor {
  final VoidCallback onUnauthenticated;

  UnauthenticatedInterceptor({required this.onUnauthenticated});

  @override
  grpc.ResponseFuture<R> interceptUnary<Q, R>(
    grpc.ClientMethod<Q, R> method,
    Q request,
    grpc.CallOptions options,
    grpc.ClientUnaryInvoker<Q, R> invoker,
  ) {
    final response = invoker(method, request, options);
    
    response.catchError((Object e) {
      if (e is grpc.GrpcError && e.code == grpc.StatusCode.unauthenticated) {
        onUnauthenticated();
      }
      throw e;
    });
    
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
