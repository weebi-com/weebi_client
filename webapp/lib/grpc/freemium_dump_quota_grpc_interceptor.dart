import 'dart:async';

import 'package:grpc/grpc.dart' as grpc;

import '../providers/freemium_dump_quota_gate.dart';

/// Watches unary gRPC calls and notifies [FreemiumDumpQuotaBinding] when the
/// server rejects a full dump for freemium quota
/// ([kFreemiumFullDumpQuotaExceeded]).
class FreemiumDumpQuotaGrpcInterceptor extends grpc.ClientInterceptor {
  @override
  grpc.ResponseFuture<R> interceptUnary<Q, R>(
    grpc.ClientMethod<Q, R> method,
    Q request,
    grpc.CallOptions options,
    grpc.ClientUnaryInvoker<Q, R> invoker,
  ) {
    final incoming = invoker(method, request, options);
    unawaited(
      incoming.catchError((Object e, StackTrace st) {
        FreemiumDumpQuotaBinding.instance.noteIfExceeded(e);
        return Future<R>.error(e, st);
      }),
    );
    return incoming;
  }
}
