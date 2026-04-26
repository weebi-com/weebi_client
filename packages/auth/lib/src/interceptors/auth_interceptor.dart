// Package imports:
import 'package:protos_weebi/grpc.dart';

/// gRPC interceptor for adding JWT authentication headers
class AuthInterceptor implements ClientInterceptor {
  final String jwt;
  
  AuthInterceptor(this.jwt);
  
  @override
  ResponseStream<R> interceptStreaming<Q, R>(
      ClientMethod<Q, R> method,
      Stream<Q> requests,
      CallOptions options,
      ClientStreamingInvoker<Q, R> invoker) {
    final newOptions = options.mergedWith(
      CallOptions(metadata: <String, String>{'authorization': jwt}),
    );
    return invoker(
      method,
      requests,
      newOptions,
    );
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    return invoker(
      method,
      request,
      options.mergedWith(
        CallOptions(metadata: <String, String>{'authorization': jwt}),
      ),
    );
  }
} 