import 'package:protos_weebi/protos_weebi_io.dart';
import 'src/dynamic_permissions_analyzer.dart';

/// Extension methods for the UserPermissions protobuf class to provide
/// convenient access and formatting of user permissions
extension UserPermissionsExtension on UserPermissions {
  /// Gets a formatted summary of article rights
  String get articleRightsSummary {
    if (!hasArticleRights()) return '';
    final rights = articleRights.rights;
    return _formatRights('Articles', rights);
  }

  /// Gets a formatted summary of boutique rights
  String get boutiqueRightsSummary {
    if (!hasBoutiqueRights()) return '';
    final rights = boutiqueRights.rights;
    return _formatRights('Boutiques', rights);
  }

  /// Gets a formatted summary of ticket rights
  String get ticketRightsSummary {
    if (!hasTicketRights()) return '';
    final rights = ticketRights.rights;
    return _formatRights('Tickets', rights);
  }

  /// Gets a formatted summary of chain rights
  String get chainRightsSummary {
    if (!hasChainRights()) return '';
    final rights = chainRights.rights;
    return _formatRights('Chains', rights);
  }

  /// Gets a formatted summary of firm rights
  String get firmRightsSummary {
    if (!hasFirmRights()) return '';
    final rights = firmRights.rights;
    return _formatRights('Firms', rights);
  }

  /// Gets a formatted summary of contact rights
  String get contactRightsSummary {
    if (!hasContactRights()) return '';
    final rights = contactRights.rights;
    return _formatRights('Contacts', rights);
  }

  /// Gets a formatted summary of user management rights
  String get userManagementRightsSummary {
    if (!hasUserManagementRights()) return '';
    final rights = userManagementRights.rights;
    return _formatRights('User Management', rights);
  }

  /// Gets a formatted summary of billing rights
  String get billingRightsSummary {
    if (!hasBillingRights()) return '';
    final rights = billingRights.rights;
    return _formatRights('Billing', rights);
  }

  /// Gets a formatted summary of boolean rights (dynamic)
  String get boolRightsSummary {
    if (!hasBoolRights()) return '';
    
    final rights = DynamicPermissionsAnalyzer.getBoolRights(boolRights);
    final activeRights = rights.entries
        .where((entry) => entry.value)
        .map((entry) => DynamicPermissionsAnalyzer.formatFieldName(entry.key))
        .toList();
    
    return activeRights.isEmpty ? '' : 'Special Rights: ${activeRights.join(", ")}';
  }

  /// Gets a complete summary of all permissions (dynamic)
  String get fullSummary {
    return DynamicPermissionsAnalyzer.getFormattedSummary(this);
  }

  /// Helper method to format rights consistently
  String _formatRights(String type, List<Right> rights) {
    final permissions = rights
        .map((r) {
          switch (r) {
            case Right.create:
              return 'C';
            case Right.read:
              return 'R';
            case Right.update:
              return 'U';
            case Right.delete:
              return 'D';
            default:
              return '';
          }
        })
        .where((p) => p.isNotEmpty)
        .toList();
    return permissions.isEmpty ? '' : '$type: ${permissions.join()}';
  }

  /// Gets a map of all permissions for display (dynamic)
  Map<String, Map<String, bool>> get permissionsMap {
    return DynamicPermissionsAnalyzer.getAllPermissions(this);
  }


  /// Creates a copy of the permissions with updated fields
  UserPermissions copyWith({
    String? userId,
    String? firmId,
    AccessLimited? limitedAccess,
    AccessFull? fullAccess,
    TicketRights? ticketRights,
    ContactRights? contactRights,
    ArticleRights? articleRights,
    BoutiqueRights? boutiqueRights,
    ChainRights? chainRights,
    FirmRights? firmRights,
    UserManagementRights? userManagementRights,
    BillingRights? billingRights,
    BoolRights? boolRights,
  }) {
    return UserPermissions()
      ..userId = userId ?? this.userId
      ..firmId = firmId ?? this.firmId
      ..limitedAccess = limitedAccess ?? this.limitedAccess
      ..fullAccess = fullAccess ?? this.fullAccess
      ..ticketRights = ticketRights ?? this.ticketRights
      ..contactRights = contactRights ?? this.contactRights
      ..articleRights = articleRights ?? this.articleRights
      ..boutiqueRights = boutiqueRights ?? this.boutiqueRights
      ..chainRights = chainRights ?? this.chainRights
      ..firmRights = firmRights ?? this.firmRights
      ..userManagementRights = userManagementRights ?? this.userManagementRights
      ..billingRights = billingRights ?? this.billingRights
      ..boolRights = boolRights ?? this.boolRights;
  }
} 