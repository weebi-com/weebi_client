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

/// Authenticated call options for ad-hoc stubs that are not wired with
/// [AuthInterceptor].
///
/// In BFF mode the access JWT is stored server-side; Envoy only injects it when
/// it sees the session cookie **or** `x-session-id`. After Stripe/PawaPay
/// redirects, third-party cookies are often missing, so cookies-only calls
/// (`callOptions`) fail as `UNAUTHENTICATED` even though the user is logged in.
CallOptions authenticatedCallOptions([String? accessToken]) {
  if (Config.isBffMode) return securedCallOptions;
  if (accessToken == null || accessToken.isEmpty) return callOptions;
  return securedCallOptions.mergedWith(
    CallOptions(metadata: {'authorization': accessToken}),
  );
}

class GrpcWebClientChannelWeebi {
  final GrpcWebClientChannel clientChannel;
  GrpcWebClientChannelWeebi()
      : clientChannel = GrpcWebClientChannel.xhr(
          Uri.parse(Config.apiUrl),
        );
}
