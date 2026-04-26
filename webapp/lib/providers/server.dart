// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:grpc/grpc_web.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/grpc/auth_interceptor.dart';
import 'package:web_admin/grpc/log_interceptor.dart';
import 'package:web_admin/grpc/operational_license_grpc_interceptor.dart';
import 'package:web_admin/grpc/server.dart';

class ArticleServiceClientProvider extends ChangeNotifier {
  final String accessToken;
  final GrpcWebClientChannel clientChannel;
  ArticleServiceClientProvider(this.clientChannel, this.accessToken)
      : _articleServiceClient = ArticleServiceClient(
          clientChannel,
          options: callOptions,
          interceptors: [
            AuthInterceptor(accessToken, isBffMode: Config.isBffMode),
            OperationalLicenseGrpcInterceptor(),
            RequestLogInterceptor(),
          ],
        );
  ArticleServiceClient _articleServiceClient;
  ArticleServiceClient get articleServiceClient => _articleServiceClient;

  set serviceClient(String value) {
    _articleServiceClient = ArticleServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: [
        AuthInterceptor(value, isBffMode: Config.isBffMode),
        OperationalLicenseGrpcInterceptor(),
        RequestLogInterceptor(),
      ],
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
          interceptors: [
            AuthInterceptor(_accessToken, isBffMode: Config.isBffMode),
            OperationalLicenseGrpcInterceptor(),
            RequestLogInterceptor(),
          ],
        );

  set serviceClient(String value) {
    _contactServiceClient = ContactServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: [
        AuthInterceptor(value, isBffMode: Config.isBffMode),
        OperationalLicenseGrpcInterceptor(),
        RequestLogInterceptor(),
      ],
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
          interceptors: [
            AuthInterceptor(_accessToken, isBffMode: Config.isBffMode),
            OperationalLicenseGrpcInterceptor(),
            RequestLogInterceptor(),
          ],
        );

  set serviceClient(String accessToken) {
    _ticketServiceClient = TicketServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: [
        AuthInterceptor(accessToken, isBffMode: Config.isBffMode),
        OperationalLicenseGrpcInterceptor(),
        RequestLogInterceptor(),
      ],
    );
    notifyListeners();
    return;
  }
}

class BillingServiceClientProvider extends ChangeNotifier {
  final String _accessToken;
  final GrpcWebClientChannel clientChannel;
  BillingServiceClient _billingServiceClient;

  BillingServiceClient get billingServiceClient => _billingServiceClient;

  BillingServiceClientProvider(this.clientChannel, this._accessToken)
      : _billingServiceClient = BillingServiceClient(
          clientChannel,
          options: callOptions,
          interceptors: [
            AuthInterceptor(_accessToken, isBffMode: Config.isBffMode),
            RequestLogInterceptor(),
          ],
        );

  set serviceClient(String value) {
    _billingServiceClient = BillingServiceClient(
      clientChannel,
      options: callOptions,
      interceptors: [
        AuthInterceptor(value, isBffMode: Config.isBffMode),
        RequestLogInterceptor(),
      ],
    );
    notifyListeners();
  }
}
