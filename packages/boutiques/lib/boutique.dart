import 'package:protos_weebi/protos_weebi_io.dart';

/// Extension methods for the Chain protobuf class to provide
/// convenient access and formatting of chain data
extension ChainExtension on Chain {
  /// Gets the total number of boutiques in this chain
  int get boutiqueCount => boutiques.length;

  /// Gets a formatted creation date string
  String get formattedCreatedAt {
    if (!hasCreationDateUTC()) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(
        creationDateUTC.seconds.toInt() * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Gets a formatted last update date string
  String get formattedLastUpdate {
    if (!hasLastUpdateTimestampUTC()) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(
        lastUpdateTimestampUTC.seconds.toInt() * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Gets a list of active boutiques (not soft-deleted)
  List<BoutiqueMongo> get activeBoutiques =>
      boutiques.where((b) => b.boutique.isDeleted == false).toList();

  /// Gets a list of soft-deleted boutiques
  List<BoutiqueMongo> get deletedBoutiques =>
      boutiques.where((b) => b.boutique.isDeleted == true).toList();

  /// Gets a summary string for the chain
  String get summary => '$name ($boutiqueCount boutiques)';

  /// Creates a copy of the chain with updated fields
  Chain copyWith({
    String? chainId,
    String? firmId,
    String? name,
    List<BoutiqueMongo>? boutiques,
    Timestamp? creationDateUTC,
    Timestamp? lastUpdateTimestampUTC,
    String? lastUpdatedByuserId,
  }) {
    return Chain()
      ..chainId = chainId ?? this.chainId
      ..firmId = firmId ?? this.firmId
      ..name = name ?? this.name
      ..boutiques.addAll(boutiques ?? this.boutiques)
      ..creationDateUTC = creationDateUTC ?? this.creationDateUTC
      ..lastUpdateTimestampUTC = lastUpdateTimestampUTC ?? this.lastUpdateTimestampUTC
      ..lastUpdatedByuserId = lastUpdatedByuserId ?? this.lastUpdatedByuserId;
  }
}

/// Extension methods for the BoutiqueMongo protobuf class to provide
/// convenient access and formatting of boutique data
extension BoutiqueMongoExtension on BoutiqueMongo {
  /// Gets the boutique name safely
  String get displayName => name.isNotEmpty ? name : boutique.name;

  /// Gets a formatted creation date string
  String get formattedCreatedAt {
    if (!hasCreationTimestampUTC()) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(
        creationTimestampUTC.seconds.toInt() * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Gets a formatted last update date string  
  String get formattedLastUpdate {
    if (!hasLastTouchTimestampUTC()) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(
        lastTouchTimestampUTC.seconds.toInt() * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  /// Gets the address as a formatted string
  String get formattedAddress {
    final address = boutique.addressFull;
    if (!address.hasStreet()) return '';
    
    final parts = <String>[];
    if (address.street.isNotEmpty) parts.add(address.street);
    if (address.hasCity() && address.city.isNotEmpty) parts.add(address.city);
    if (address.hasCode() && address.code.isNotEmpty) parts.add(address.code);
    
    return parts.join(', ');
  }

  /// Gets the phone number as a formatted string
  String get formattedPhone {
    final phone = boutique.phone;
    if (!phone.hasNumber()) return '';
    if (phone.hasCountryCode()) {
      return '+${phone.countryCode} ${phone.number}';
    }
    return phone.number;
  }

  /// Gets the email as a formatted string
  String get formattedEmail {
    // Use the actual mail field from protobuf
    if (boutique.hasMail() && boutique.mail.isNotEmpty) {
      return boutique.mail;
    }
    // Fallback to additionalAttributes for backward compatibility
    return additionalAttributes['email'] ?? '';
  }

  /// Gets a human-friendly lifecycle label (soft-delete aware)
  String get statusText => boutique.isDeleted ? 'Supprimée' : 'Active';

  /// Boutique billing currency (ISO 4217) when available.
  String get currencyCode {
    if (boutique.hasCurrency() && boutique.currency.trim().isNotEmpty) {
      return boutique.currency.trim().toUpperCase();
    }
    return '';
  }

  /// Gets a map of boutique details for display
  Map<String, String> get detailsMap {
    return {
      'Name': displayName,
      'Status': statusText,
      'Currency': currencyCode.isNotEmpty ? currencyCode : 'N/A',
      'Email': formattedEmail.isNotEmpty ? formattedEmail : 'No email provided',
      'Address': formattedAddress,
      'Phone': formattedPhone,
      'Created': formattedCreatedAt,
      'Last Update': formattedLastUpdate,
      'Device Count': devices.length.toString(),
    };
  }

  /// Checks if the boutique has a logo
  bool get hasLogo => logo.isNotEmpty && logoExtension.isNotEmpty;

  /// Creates a copy of the boutique with updated fields
  BoutiqueMongo copyWith({
    BoutiquePb? boutique,
    String? boutiqueId,
    String? firmId,
    String? chainId,
    Timestamp? creationTimestampUTC,
    String? name,
    List<Device>? devices,
    Timestamp? lastTouchTimestampUTC,
    List<int>? logo,
    String? logoExtension,
    Map<String, String>? additionalAttributes,
  }) {
    return BoutiqueMongo()
      ..boutique = boutique ?? this.boutique
      ..boutiqueId = boutiqueId ?? this.boutiqueId
      ..firmId = firmId ?? this.firmId
      ..chainId = chainId ?? this.chainId
      ..creationTimestampUTC = creationTimestampUTC ?? this.creationTimestampUTC
      ..name = name ?? this.name
      ..devices.addAll(devices ?? this.devices)
      ..lastTouchTimestampUTC = lastTouchTimestampUTC ?? this.lastTouchTimestampUTC
      ..logo = logo ?? this.logo
      ..logoExtension = logoExtension ?? this.logoExtension
      ..additionalAttributes.addAll(additionalAttributes ?? this.additionalAttributes);
  }
} 