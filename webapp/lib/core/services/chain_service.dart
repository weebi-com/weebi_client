import 'dart:async';
import 'package:protos_weebi/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'grpc_client_service.dart';
import '../constants/values.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class ChainService {
  final GrpcClientService _grpcClientService = GrpcClientService();

  Future<StatusResponse> createOneChain({
    String? chainId,
    String? firmId,
    String? name,
    List<BoutiquePb>? boutiques,
    Timestamp? lastUpdateTimestampUTC,
    String? lastUpdatedByuserId,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      final options = CallOptions(metadata: {'authorization': '$token'});

      final response = await stub.createOneChain(
        Chain(
          name: name,
          firmId: firmId,
          chainId: chainId,
          lastUpdateTimestampUTC: lastUpdateTimestampUTC,
          boutiques: [], // empty
          lastUpdatedByuserId: lastUpdatedByuserId,
        ),
        options: options,
      );

      return response;
    } catch (e) {
      print('Erreur lors de la création de la chaine: $e');
      rethrow;
    }
  }

  Future<StatusResponse> updateOneChain(
      {required String chainId,
      required String lastUpdatedByuserId,
      String? firmId,
      String? name,
      List<BoutiquePb>? boutiques,
      Timestamp? lastUpdateTimestampUTC,
      String? currency,
      bool? isDualCurrencyEnabled,
      String? secondaryDisplayCurrency}) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      final options = CallOptions(metadata: {'authorization': '$token'});

      final req = ChainRequest(chainId: chainId, name: name);
      if (currency != null) {
        req.currency = currency;
      }
      if (isDualCurrencyEnabled != null) {
        req.isDualCurrencyEnabled = isDualCurrencyEnabled;
      }
      if (secondaryDisplayCurrency != null && secondaryDisplayCurrency.isNotEmpty ) {
        req.secondaryDisplayCurrency = secondaryDisplayCurrency;
      }

      final response = await stub.updateOneChain(
        req,
        options: options,
      );

      return response;
    } catch (e) {
      print('Erreur lors de la modification de la chaine: $e');
      rethrow;
    }
  }

  Future<ReadAllChainsResponse> readAllChains() async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      final options = CallOptions(metadata: {'authorization': '$token'});

      final response = await stub.readAllChains(
        Empty(),
        options: options,
      );

      return response;
    } catch (e) {
      print('Erreur lors de la récuperation de la chaine: $e');
      rethrow;
    }
  }
}
