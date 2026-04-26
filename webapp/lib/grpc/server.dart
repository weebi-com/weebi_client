// Package imports:

import 'package:grpc/grpc_web.dart';
import 'package:web_admin/environment.dart';

CallOptions get callOptions => Config.isBffMode
    ? WebCallOptions(withCredentials: true, timeout: const Duration(seconds: 30))
    : CallOptions(timeout: const Duration(seconds: 30));

class GrpcWebClientChannelWeebi {
  final GrpcWebClientChannel clientChannel;
  GrpcWebClientChannelWeebi()
      : clientChannel = GrpcWebClientChannel.xhr(
          Uri.parse(Config.apiUrl),
        );
}
