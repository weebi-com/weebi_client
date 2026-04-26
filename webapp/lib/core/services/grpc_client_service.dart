import '../../environment.dart';
import 'package:grpc/grpc_web.dart';

class GrpcClientService {
  final GrpcWebClientChannel channel;

  GrpcClientService()
      : channel = GrpcWebClientChannel.xhr(Uri.parse(Config.apiUrl));
}
