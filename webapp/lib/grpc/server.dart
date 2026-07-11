// Package imports:

import 'package:grpc/grpc_web.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/providers/session_recovery.dart';

CallOptions get callOptions => Config.isBffMode
    ? WebCallOptions(withCredentials: true, timeout: const Duration(seconds: 30))
    : CallOptions(timeout: const Duration(seconds: 30));

/// gRPC call options used for authenticated requests (injects BFF session id).
CallOptions get securedCallOptions => callOptions.mergedWith(
      CallOptions(
        providers: [
          SessionRecoveryBinding.instance.ensureSessionForRequest,
        ],
      ),
    );

class GrpcWebClientChannelWeebi {
  final GrpcWebClientChannel clientChannel;
  GrpcWebClientChannelWeebi()
      : clientChannel = GrpcWebClientChannel.xhr(
          Uri.parse(Config.apiUrl),
        );
}
