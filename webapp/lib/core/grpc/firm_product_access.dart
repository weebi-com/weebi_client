import 'package:grpc/grpc.dart' as grpc;
import 'package:protos_weebi/grpc.dart' show GrpcError;

/// Same substring as [kOperationalLicenseRequired] on the server (`fence_service`
/// operational license gate for ticket / article / contact RPCs).
const kOperationalLicenseRequired = 'OPERATIONAL_LICENSE_REQUIRED';

/// True when [error] is the firm operational-license denial (no active seat and
/// not the firm creator per JWT).
bool isOperationalLicenseDenied(Object error) {
  if (error is! GrpcError) return false;
  if (error.code != grpc.StatusCode.failedPrecondition) return false;
  final msg = error.message ?? '';
  return msg.contains(kOperationalLicenseRequired);
}
