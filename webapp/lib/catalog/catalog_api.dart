import 'package:protos_weebi/protos_weebi_io.dart';

/// Narrow article API used by catalog CRUD so tests can fake it.
abstract class CatalogApi {
  Future<CalibresResponse> readAll(ReadAllRequest request);
  Future<CalibresIdsResponse> readAllIds(ReadIdsRequest request);
  Future<CalibrePb> readOne(ReadCalibreRequest request);
  Future<StatusResponse> createOne(CalibreRequest request);
  Future<StatusResponse> updateOne(CalibreRequest request);
  Future<StatusResponse> deleteOne(CalibreRequest request);
}

class GrpcCatalogApi implements CatalogApi {
  GrpcCatalogApi(this._client);

  final ArticleServiceClient _client;

  @override
  Future<CalibresResponse> readAll(ReadAllRequest request) =>
      _client.readAll(request);

  @override
  Future<CalibresIdsResponse> readAllIds(ReadIdsRequest request) =>
      _client.readAllIds(request);

  @override
  Future<CalibrePb> readOne(ReadCalibreRequest request) =>
      _client.readOne(request);

  @override
  Future<StatusResponse> createOne(CalibreRequest request) =>
      _client.createOne(request);

  @override
  Future<StatusResponse> updateOne(CalibreRequest request) =>
      _client.updateOne(request);

  @override
  Future<StatusResponse> deleteOne(CalibreRequest request) =>
      _client.deleteOne(request);
}
