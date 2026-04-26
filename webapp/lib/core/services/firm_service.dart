import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/grpc/server.dart';
import 'grpc_client_service.dart';
import '../constants/values.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class FirmService {
  final GrpcClientService _grpcClientService = GrpcClientService();

  Future<CreateFirmResponse> createFirm({
    required String name,
    String? defaultCurrency,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      if (!Config.isBffMode && (token == null || token.isEmpty)) {
        throw const GrpcError.unauthenticated('Missing access token');
      }
      final options = Config.isBffMode
          ? callOptions
          : CallOptions(metadata: {'authorization': token!});

      final req = CreateFirmRequest(name: name);
      if (defaultCurrency != null &&
          defaultCurrency.trim().isNotEmpty &&
          defaultCurrency.trim().length == 3) {
        req.currency = defaultCurrency.trim().toUpperCase();
      }

      final response = await stub.createFirm(
        req,
        options: options,
      );

      return CreateFirmResponse(
          firm: response.firm, statusResponse: response.statusResponse);
    } catch (e) {
      debugPrint('Erreur lors de la création de la chaine: $e');
      rethrow;
    }
  }

  Future<Firm> readOneFirm() async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      if (!Config.isBffMode && (token == null || token.isEmpty)) {
        throw const GrpcError.unauthenticated('Missing access token');
      }
      final options = Config.isBffMode
          ? callOptions
          : CallOptions(metadata: {'authorization': token!});

      final response = await stub.readOneFirm(Empty(), options: options);

      return response;
    } catch (e) {
      debugPrint('Erreur lors de la récuperation de la chaine: $e');
      rethrow;
    }
  }
}
