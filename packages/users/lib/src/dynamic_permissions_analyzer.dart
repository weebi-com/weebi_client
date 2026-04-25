import 'package:protos_weebi/protos_weebi_io.dart';

/// Dynamic permissions analyzer using protobuf runtime reflection
/// 
/// This class uses the protobuf `byIndex` field info to dynamically discover
/// all boolean rights fields (BoolRights) at runtime, eliminating the need for
/// hardcoded field lists. When new boolean permission fields are added to the
/// BoolRights protobuf definition, they are automatically discovered without
/// any code changes.
class DynamicPermissionsAnalyzer {
  /// Gets all boolean rights using truly dynamic discovery via byIndex
  static Map<String, bool> getBoolRights(BoolRights boolRights) {
    final rights = <String, bool>{};
    
    // Use byIndex to get ALL fields dynamically - no hardcoded lists!
    final fieldsByIndex = boolRights.info_.byIndex;
    
    for (final fieldInfo in fieldsByIndex) {
      final fieldName = fieldInfo.name;
      
      // Skip internal fields (if any)
      if (fieldName.startsWith('_') || fieldName.isEmpty) {
        continue;
      }
      
      try {
        // Get the field value using the tag number
        final value = boolRights.getField(fieldInfo.tagNumber);
        if (value is bool) {
          rights[fieldName] = value;
        }
      } catch (e) {
        // Skip fields that can't be accessed
        continue;
      }
        }
    
    return rights;
  }
  
  /// Gets all rights from a rights object (simple type-specific approach)
  static Map<String, bool> getRightsFromProtobuf(GeneratedMessage obj) {
    final rights = <String, bool>{};
    
    // For rights objects, check if they have a 'rights' list field
    if (obj is ArticleRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is BoutiqueRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is TicketRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is ChainRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is FirmRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is ContactRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is UserManagementRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    } else if (obj is BillingRights) {
      rights['rights'] = obj.rights.isNotEmpty;
    }
    
    return rights;
  }
  
  /// Gets all permissions from UserPermissions dynamically
  static Map<String, Map<String, bool>> getAllPermissions(UserPermissions permissions) {
    final allPermissions = <String, Map<String, bool>>{};
    
    // Get all rights objects
    final rightsObjects = {
      'Article Rights': permissions.hasArticleRights() ? permissions.articleRights : null,
      'Boutique Rights': permissions.hasBoutiqueRights() ? permissions.boutiqueRights : null,
      'Ticket Rights': permissions.hasTicketRights() ? permissions.ticketRights : null,
      'Chain Rights': permissions.hasChainRights() ? permissions.chainRights : null,
      'Firm Rights': permissions.hasFirmRights() ? permissions.firmRights : null,
      'Contact Rights': permissions.hasContactRights() ? permissions.contactRights : null,
      'User Management Rights': permissions.hasUserManagementRights() ? permissions.userManagementRights : null,
      'Billing Rights': permissions.hasBillingRights() ? permissions.billingRights : null,
      'Special Rights': permissions.hasBoolRights() ? permissions.boolRights : null,
    };
    
    for (final entry in rightsObjects.entries) {
      if (entry.value != null) {
        if (entry.key == 'Special Rights') {
          allPermissions[entry.key] = getBoolRights(entry.value as BoolRights);
        } else {
          allPermissions[entry.key] = getRightsFromProtobuf(entry.value as GeneratedMessage);
        }
      }
    }
    
    return allPermissions;
  }
  
  /// Gets a formatted summary of all permissions
  static String getFormattedSummary(UserPermissions permissions) {
    final allPermissions = getAllPermissions(permissions);
    final summaries = <String>[];
    
    for (final entry in allPermissions.entries) {
      final activeRights = entry.value.entries
          .where((right) => right.value)
          .map((right) => formatFieldName(right.key))
          .toList();
      
      if (activeRights.isNotEmpty) {
        summaries.add('${entry.key}: ${activeRights.join(", ")}');
      }
    }
    
    return summaries.isEmpty ? 'No permissions' : summaries.join(', ');
  }
  
  /// Helper method to format field names for display
  static String formatFieldName(String fieldName) {
    // Convert camelCase to readable format
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)!}')
        .replaceAllMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase())
        .trim();
  }
}
