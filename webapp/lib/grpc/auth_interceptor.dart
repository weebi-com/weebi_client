// Package imports:
import 'package:protos_weebi/grpc.dart';

class AuthInterceptor implements ClientInterceptor {
  final String jwt;
  final bool isBffMode;
  AuthInterceptor(this.jwt, {this.isBffMode = false});
  
  @override
  ResponseStream<R> interceptStreaming<Q, R>(
      ClientMethod<Q, R> method,
      Stream<Q> requests,
      CallOptions options,
      ClientStreamingInvoker<Q, R> invoker) {
    var newOptions = options;
    if (isBffMode) {
      // In BFF mode, we don't add JWT - let browser handle cookies
    } else {
      newOptions = options.mergedWith(
        CallOptions(metadata: <String, String>{'authorization': jwt}),
      );
    }
    return invoker(
      method,
      requests,
      newOptions,
    );
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    var newOptions = options;
    if (isBffMode) {
      // In BFF mode, we don't add JWT - let browser handle cookies
    } else {
      newOptions = options.mergedWith(
        CallOptions(metadata: <String, String>{'authorization': jwt}),
      );
    }
    return invoker(
      method,
      request,
      newOptions,
    );
  }
}
