import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:protos_weebi/data_dummy.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/grpc/server.dart';
import 'package:web_admin/token/jwt.dart';
import 'grpc_client_service.dart';
import '../constants/values.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class UserService {
  final GrpcClientService _grpcClientService = GrpcClientService();

  Future<PendingUserResponse> createPendingUser({
    required String mail,
    required String firstname,
    required String lastname,
    required String countryCode,
    required String phone,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      if (Config.isBffMode || (token != null && token.isNotEmpty)) {
        final currentUser = Config.isBffMode
            ? (await stub.readOneUser(UserId(), options: callOptions)).user
            : null;
        final permissions = Config.isBffMode
            ? currentUser!.permissions
            : JsonWebToken.parse(token!).permissions;
        final options = Config.isBffMode
            ? callOptions
            : CallOptions(metadata: {'authorization': token!});

        int country = int.parse(countryCode);

        // TODO pass user permissions dynamically here

        // TODO get actual chainId or boutiqueId here, cheating here because firmId == 1st chainId == 1st boutiqueId

        final userPermissions = UserPermissions.create()
          ..articleRights = RightSalesperson.article
          ..boutiqueRights = RightSalesperson.boutique
          ..contactRights = RightSalesperson.contact
          ..ticketRights = RightSalesperson.ticket
          ..boolRights = BoolRights()
          ..firmId = permissions.firmId
          ..limitedAccess = AccessLimited(
              boutiqueIds: BoutiqueIds(ids: [permissions.firmId]),
              chainIds: ChainIds(ids: [permissions.firmId]));

        final response = await stub.createPendingUser(
          PendingUserRequest(
              mail: mail,
              firstname: firstname,
              lastname: lastname,
              phone: Phone(countryCode: country, number: phone),
              permissions: userPermissions),
          options: options,
        );

        return PendingUserResponse(
            statusResponse: response.statusResponse,
            userPublic: response.userPublic);
      } else {
        return PendingUserResponse.create();
      }
    } catch (e) {
      debugPrint('Erreur lors de la création de l\'utilisateur: $e');
      rethrow;
    }
  }

  Future<UserPublic?> readOneUser({required String userId}) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      if (!Config.isBffMode && (token == null || token.isEmpty)) return null;

      final options = Config.isBffMode
          ? callOptions
          : CallOptions(metadata: {'authorization': token!});
      final response = await stub.readOneUser(
        UserId()..userId = userId,
        options: options,
      );

      return response.user;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }

  Future<UsersPublic> readAllUsers() async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      final options = Config.isBffMode
          ? callOptions
          : CallOptions(metadata: {'authorization': token ?? ''});

      final response = await stub.readAllUsers(options: options, Empty());

      return UsersPublic(
        users: response.users,
      );
    } catch (e) {
      debugPrint('Erreur lors de la récupération des utilisateurs: $e');
      rethrow;
    }
  }

  Future<StatusResponse> deleteOneUser({required String userId}) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(SharePrefKeys.accessToken);
      final options = Config.isBffMode
          ? callOptions
          : CallOptions(metadata: {'authorization': token ?? ''});

      final response =
          await stub.deleteOneUser(UserId(userId: userId), options: options);

      return response;
    } catch (e) {
      debugPrint('Erreur lors de la suppression de l\'utilisateur: $e');
      rethrow;
    }
  }
}
