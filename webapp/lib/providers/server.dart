// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' show ClientInterceptor;
import 'package:grpc/grpc_web.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/billing/billing_rpc.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/grpc/auth_interceptor.dart';
import 'package:web_admin/grpc/freemium_dump_quota_grpc_interceptor.dart';
import 'package:web_admin/grpc/log_interceptor.dart';
import 'package:web_admin/grpc/operational_license_grpc_interceptor.dart';
import 'package:web_admin/grpc/server.dart';
import 'package:web_admin/grpc/unauthenticated_interceptor.dart';

List<ClientInterceptor> _dataServiceInterceptors(String accessToken) => [
      AuthInterceptor(accessToken, isBffMode: Config.isBffMode),
      UnauthenticatedInterceptor(),
      OperationalLicenseGrpcInterceptor(),
      FreemiumDumpQuotaGrpcInterceptor(),
      RequestLogInterceptor(),
    ];

class ArticleServiceClientProvider extends ChangeNotifier {
  final String accessToken;
  final GrpcWebClientChannel clientChannel;
  ArticleServiceClientProvider(this.clientChannel, this.accessToken)
      : _articleServiceClient = ArticleServiceClient(
          clientChannel,
          options: callOptions,
          interceptors: _dataServiceInterceptors(accessToken),
        );
  ArticleServiceClient _articleServiceClient;
  ArticleServiceClient get articleServiceClient => _articleServiceClient;

  set serviceClient(String value) {
    _articleServiceClient = ArticleServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: _dataServiceInterceptors(value),
    );
    notifyListeners();
    return;
  }
}

/// FenceServiceClient is provided by FenceServiceClientProviderV2 from users_weebi.
/// See root_app.dart for wiring with GrpcWebClientChannel.

class ContactServiceClientProvider extends ChangeNotifier {
  final String _accessToken;
  final GrpcWebClientChannel clientChannel;
  ContactServiceClient _contactServiceClient;
  ContactServiceClient get contactServiceClient => _contactServiceClient;
  ContactServiceClientProvider(this.clientChannel, this._accessToken)
      : _contactServiceClient = ContactServiceClient(
          clientChannel,
          options: callOptions,
          interceptors: _dataServiceInterceptors(_accessToken),
        );

  set serviceClient(String value) {
    _contactServiceClient = ContactServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: _dataServiceInterceptors(value),
    );
    notifyListeners();
    return;
  }
}

class TicketServiceClientProvider extends ChangeNotifier {
  final String _accessToken;
  final GrpcWebClientChannel clientChannel;
  TicketServiceClient _ticketServiceClient;
  TicketServiceClient get ticketServiceClient => _ticketServiceClient;
  TicketServiceClientProvider(this.clientChannel, this._accessToken)
      : _ticketServiceClient = TicketServiceClient(
          clientChannel,
          options: callOptions,
          interceptors: _dataServiceInterceptors(_accessToken),
        );

  set serviceClient(String accessToken) {
    _ticketServiceClient = TicketServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: _dataServiceInterceptors(accessToken),
    );
    notifyListeners();
    return;
  }
}

class BillingServiceClientProvider extends ChangeNotifier {
  final String _accessToken;
  final GrpcWebClientChannel? clientChannel;
  BillingServiceClient? _billingServiceClient;
  late BillingRpc _billingRpc;

  BillingServiceClient get billingServiceClient {
    final client = _billingServiceClient;
    if (client == null) {
      throw StateError(
        'BillingServiceClient is unavailable (test BillingRpc-only provider)',
      );
    }
    return client;
  }

  /// Prefer this in UI code so widget tests can inject a [FakeBillingRpc].
  BillingRpc get billingRpc => _billingRpc;

  BillingServiceClientProvider(GrpcWebClientChannel channel, this._accessToken)
      : clientChannel = channel,
        _billingServiceClient = BillingServiceClient(
          channel,
          options: callOptions,
          interceptors: [
            AuthInterceptor(_accessToken, isBffMode: Config.isBffMode),
            UnauthenticatedInterceptor(),
            RequestLogInterceptor(),
          ],
        ) {
    _billingRpc = GrpcBillingRpc(_billingServiceClient!);
  }

  /// Test / harness constructor: no live gRPC channel.
  BillingServiceClientProvider.forTest(BillingRpc rpc)
      : clientChannel = null,
        _accessToken = '',
        _billingServiceClient = null,
        _billingRpc = rpc;

  set serviceClient(String value) {
    final channel = clientChannel;
    if (channel == null) {
      throw StateError('Cannot refresh gRPC client on forTest provider');
    }
    _billingServiceClient = BillingServiceClient(
      channel,
      options: callOptions,
      interceptors: [
        AuthInterceptor(value, isBffMode: Config.isBffMode),
        UnauthenticatedInterceptor(),
        RequestLogInterceptor(),
      ],
    );
    _billingRpc = GrpcBillingRpc(_billingServiceClient!);
    notifyListeners();
  }
}

class StatsServiceClientProvider extends ChangeNotifier {
  final String _accessToken;
  final GrpcWebClientChannel clientChannel;
  StatsServiceClient _statsServiceClient;

  StatsServiceClient get statsServiceClient => _statsServiceClient;

  StatsServiceClientProvider(this.clientChannel, this._accessToken)
      : _statsServiceClient = StatsServiceClient(
          clientChannel,
          options: callOptions,
          interceptors: _dataServiceInterceptors(_accessToken),
        );

  set serviceClient(String value) {
    _statsServiceClient = StatsServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: _dataServiceInterceptors(value),
    );
    notifyListeners();
  }
}
