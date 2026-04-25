import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart'
    show
        GeneratedMessage,
        PbList,
        Address,
        Phone,
        Timestamp,
        BoutiqueMongo,
        BoutiquePb,
        Chain,
        Device;
import 'boutique.dart';
import 'src/l10n/boutique_ui_strings.dart';

class BoutiqueDynamicBody<T extends GeneratedMessage> extends StatelessWidget {
  final T pbObject;

  const BoutiqueDynamicBody({super.key, required this.pbObject});

  @override
  Widget build(BuildContext context) {
    // Use Column instead of ListView since we're already inside a ScrollView
    final fields = <Widget>[];

    for (int index = 0; index < pbObject.info_.fieldInfo.length; index++) {
      final fieldInfo = pbObject.info_.fieldInfo[index];
      final fieldName = fieldInfo?.name ?? '';
      final fieldValue =
          fieldInfo == null ? null : pbObject.getField(fieldInfo.tagNumber);

      // Skip technical fields that expose raw data
      if (_shouldSkipField(fieldName, fieldValue)) {
        continue;
      }

      fields.add(BoutiqueProtobufFieldWidget(
        fieldName: fieldName,
        fieldValue: fieldValue,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }
}

class BoutiqueProtobufFieldWidget extends StatelessWidget {
  final String fieldName;
  final dynamic fieldValue;

  const BoutiqueProtobufFieldWidget(
      {super.key, required this.fieldName, required this.fieldValue});

  @override
  Widget build(BuildContext context) {
    return _buildBoutiqueField(fieldName, fieldValue);
  }
}

Widget _buildBoutiqueField(String fieldName, dynamic fieldValue) {
  // Handle null values
  if (fieldValue == null) {
    return const SizedBox.shrink();
  }

  switch (fieldValue.runtimeType) {
    case const (String):
      if (fieldValue.isEmpty) return const SizedBox.shrink();
      return ListTile(
        leading: _getFieldIcon(fieldName),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue),
      );

    case const (int) || const (double):
      if (fieldValue == 0) return const SizedBox.shrink();
      return ListTile(
        leading: _getFieldIcon(fieldName),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue.toString()),
      );

    case const (bool):
      return ListTile(
        leading: _getFieldIcon(fieldName),
        title: Text(_formatFieldName(fieldName)),
        trailing: Icon(
          fieldValue ? Icons.check_circle : Icons.cancel,
          color: fieldValue ? Colors.green : Colors.red,
        ),
      );

    case const (Timestamp):
      final dateTime = fieldValue.toDateTime();
      return ListTile(
        leading: _getFieldIcon(fieldName),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        ),
      );

    case const (Phone):
      if (!fieldValue.hasNumber() || fieldValue.number.isEmpty) {
        return const SizedBox.shrink();
      }
      return ExpansionTile(
        leading: const Icon(Icons.phone),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(
            fieldValue.hasCountryCode()
                ? '+${fieldValue.countryCode} ${fieldValue.number}'
                : fieldValue.number),
        children: [
          if (fieldValue.hasCountryCode())
            ListTile(
              title: const Text('Code pays'),
              subtitle: Text('+${fieldValue.countryCode}'),
            ),
          ListTile(
            title: const Text('Numéro'),
            subtitle: Text(fieldValue.number),
          ),
        ],
      );

    case const (Address):
      if (!fieldValue.hasStreet() || fieldValue.street.isEmpty) {
        return const SizedBox.shrink();
      }
      return ExpansionTile(
        leading: const Icon(Icons.location_on),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(_formatAddress(fieldValue)),
        children: [
          if (fieldValue.street.isNotEmpty)
            ListTile(
              title: const Text('Rue'),
              subtitle: Text(fieldValue.street),
            ),
          if (fieldValue.hasCode() && fieldValue.code.isNotEmpty)
            ListTile(
              title: const Text('Code postal'),
              subtitle: Text(fieldValue.code),
            ),
          if (fieldValue.hasCity() && fieldValue.city.isNotEmpty)
            ListTile(
              title: const Text('Ville'),
              subtitle: Text(fieldValue.city),
            ),
          if (fieldValue.hasCountry())
            ListTile(
                title: const Text('Pays'),
              subtitle: Text(fieldValue.country.toString()),
            ),
          if (fieldValue.hasLatitude())
            ListTile(
              title: const Text('Latitude'),
              subtitle: Text(fieldValue.latitude.toString()),
            ),
          if (fieldValue.hasLongitude())
            ListTile(
              title: const Text('Longitude'),
              subtitle: Text(fieldValue.longitude.toString()),
            ),
        ],
      );

    case const (BoutiqueMongo):
      final boutique = fieldValue as BoutiqueMongo;
      return ExpansionTile(
        leading: const Icon(Icons.store),
        title: Text(boutique.displayName),
        subtitle: Text(boutique.formattedPhone),
        children: [
          _buildBoutiqueSummary(boutique),
          // Display the nested BoutiquePb fields
          if (boutique.boutique.hasMail() && boutique.boutique.mail.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(boutique.boutique.mail),
            ),
        ],
      );

    case const (BoutiquePb):
      final boutiquePb = fieldValue as BoutiquePb;
      return ExpansionTile(
        leading: const Icon(Icons.store_mall_directory),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(
            boutiquePb.name.isNotEmpty ? boutiquePb.name : 'Infos boutique'),
        children: [
          _buildBoutiquePbSummary(boutiquePb),
        ],
      );

    case const (Chain):
      final chain = fieldValue as Chain;
      return ExpansionTile(
        leading: const Icon(Icons.account_tree),
        title: Text(chain.name),
        subtitle:
            Text(chain.summary.isNotEmpty ? chain.summary : 'Infos chaîne'),
        children: [
          _buildChainSummary(chain),
        ],
      );

    case const (Device):
      final device = fieldValue as Device;
      return ExpansionTile(
        leading: const Icon(Icons.devices),
        title: Text('Appareil ${device.deviceId}'),
        subtitle: Text('Statut: ${device.status ? "Actif" : "Inactif"}'),
        children: [
          _buildDeviceSummary(device),
        ],
      );

    case const (PbList):
      final list = fieldValue as PbList;
      if (list.isEmpty) return const SizedBox.shrink();

      return ExpansionTile(
        leading: _getFieldIcon(fieldName),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text('${list.length} élément(s)'),
        children: list.map<Widget>((item) {
          // Handle different types of items in the list
          if (item is BoutiqueMongo) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildBoutiqueSummary(item),
            );
          } else if (item is BoutiquePb) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildBoutiquePbSummary(item),
            );
          } else if (item is Device) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildDeviceSummary(item),
            );
          } else if (item is Chain) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildChainSummary(item),
            );
          } else {
            // Fallback to simple display for other types
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ListTile(
                leading: _getFieldIcon(fieldName),
                title: Text(_formatFieldName(fieldName)),
                subtitle: Text(item.toString()),
              ),
            );
          }
        }).toList(),
      );

    default:
      if (fieldValue.toString().isEmpty || fieldValue.toString() == '[]') {
        return const SizedBox.shrink();
      }
      return ListTile(
        leading: _getFieldIcon(fieldName),
        title: Text(_formatFieldName(fieldName)),
        subtitle: Text(fieldValue.toString()),
      );
  }
}

String _formatFieldName(String fieldName) {
  // Convert camelCase/snake_case to readable format
  return fieldName
      .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
}

String _formatAddress(Address address) {
  final parts = <String>[];
  if (address.street.isNotEmpty) parts.add(address.street);
  if (address.hasCity() && address.city.isNotEmpty) parts.add(address.city);
  if (address.hasCode() && address.code.isNotEmpty) parts.add(address.code);
  return parts.join(', ');
}

Icon _getFieldIcon(String fieldName) {
  final field = fieldName.toLowerCase();

  if (field.contains('id')) return const Icon(Icons.fingerprint);
  if (field.contains('name')) return const Icon(Icons.label);
  if (field.contains('date') || field.contains('time')) {
    return const Icon(Icons.schedule);
  }
  if (field.contains('status')) return const Icon(Icons.info);
  if (field.contains('phone')) return const Icon(Icons.phone);
  if (field.contains('address')) return const Icon(Icons.location_on);
  if (field.contains('logo')) return const Icon(Icons.image);
  if (field.contains('device')) return const Icon(Icons.devices);
  if (field.contains('boutique')) return const Icon(Icons.store);
  if (field.contains('chain')) return const Icon(Icons.account_tree);
  if (field.contains('firm')) return const Icon(Icons.business);
  if (field.contains('user')) return const Icon(Icons.person);
  if (field.contains('promo')) return const Icon(Icons.local_offer);

  return const Icon(Icons.info_outline);
}

// Helper method to determine if a field should be skipped
bool _shouldSkipField(String fieldName, dynamic fieldValue) {
  // Skip empty or null values
  if (fieldValue == null) return true;

  // Skip technical or sensitive fields that expose raw data
  final technicalFields = [
    'boutiques', // This is the main culprit - raw boutique list
    'devices', // Raw device list
    'licenses', // Sensitive licenses information
    'stripeCustomerId', // Sensitive stripe customer ID
    'providerCustomerIds', // Sensitive provider customer IDs
    'referralCode', // Sensitive referral code
    'referralCreditBalanceCents', // Sensitive referral credit balance
    'subscriptionPlan', // Deprecated sensitive field
    'subscriptionSeats', // Deprecated sensitive field
    'subscriptionStartTimestampUTC', // Deprecated sensitive field
    'subscriptionEndTimestampUTC', // Deprecated sensitive field
    'info_', // Internal protobuf info
    'unknownFields', // Internal protobuf fields
    'hasRequiredFields', // Internal protobuf methods
  ];

  if (technicalFields.contains(fieldName)) {
    return true;
  }

  // Skip fields that are PbList of complex objects (handled separately)
  if (fieldValue is PbList && fieldValue.isNotEmpty) {
    final firstItem = fieldValue.first;
    if (firstItem is BoutiqueMongo ||
        firstItem is BoutiquePb ||
        firstItem is Device ||
        firstItem is Chain) {
      return true; // These are handled by custom summary builders
    }
  }

  return false;
}

// Custom summary builders for complex objects
Widget? _secondaryDisplayCurrencySummaryTile({
  required bool hasDualFlag,
  required bool dualEnabled,
  required bool hasSecondary,
  required String secondary,
}) {
  if (!hasDualFlag || !dualEnabled) return null;
  final trimmed = hasSecondary ? secondary.trim() : '';
  if (trimmed.isEmpty) return null;
  return ListTile(
    leading: const Icon(Icons.currency_exchange),
    title: const Text(BoutiqueUiStrings.secondaryDisplayCurrencyLabel),
    subtitle: Text(trimmed.toUpperCase()),
  );
}

Widget _buildBoutiqueSummary(BoutiqueMongo boutique) {
  final pb = boutique.boutique;
  final secondaryTile = _secondaryDisplayCurrencySummaryTile(
    hasDualFlag: pb.hasIsDualCurrencyEnabled(),
    dualEnabled: pb.isDualCurrencyEnabled,
    hasSecondary: pb.hasSecondaryDisplayCurrency(),
    secondary: pb.secondaryDisplayCurrency,
  );
  return Column(
    children: [
      if (boutique.currencyCode.isNotEmpty)
        ListTile(
          leading: const Icon(Icons.monetization_on_outlined),
          title: const Text('Currency'),
          subtitle: Text(boutique.currencyCode),
        ),
      if (secondaryTile != null) secondaryTile,
      if (boutique.boutique.hasMail() && boutique.boutique.mail.isNotEmpty)
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(boutique.boutique.mail),
        ),
      if (boutique.boutique.hasAddressFull())
        _buildAddressSummary(boutique.boutique.addressFull),
      if (boutique.boutique.hasPhone())
        _buildPhoneSummary(boutique.boutique.phone),

      // Note: BoutiquePb doesn't have timestamp field
    ],
  );
}

Widget _buildBoutiquePbSummary(BoutiquePb boutique) {
  final secondaryTile = _secondaryDisplayCurrencySummaryTile(
    hasDualFlag: boutique.hasIsDualCurrencyEnabled(),
    dualEnabled: boutique.isDualCurrencyEnabled,
    hasSecondary: boutique.hasSecondaryDisplayCurrency(),
    secondary: boutique.secondaryDisplayCurrency,
  );
  return Column(
    children: [
      if (boutique.hasCurrency() && boutique.currency.trim().isNotEmpty)
        ListTile(
          leading: const Icon(Icons.monetization_on_outlined),
          title: const Text('Currency'),
          subtitle: Text(boutique.currency.trim().toUpperCase()),
        ),
      if (secondaryTile != null) secondaryTile,
      if (boutique.hasMail() && boutique.mail.isNotEmpty)
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(boutique.mail),
        ),
      if (boutique.hasAddressFull()) _buildAddressSummary(boutique.addressFull),
      if (boutique.hasPhone()) _buildPhoneSummary(boutique.phone),

      // Note: BoutiquePb doesn't have timestamp field
    ],
  );
}

Widget _buildChainSummary(Chain chain) {
  final secondaryTile = _secondaryDisplayCurrencySummaryTile(
    hasDualFlag: chain.hasIsDualCurrencyEnabled(),
    dualEnabled: chain.isDualCurrencyEnabled,
    hasSecondary: chain.hasSecondaryDisplayCurrency(),
    secondary: chain.secondaryDisplayCurrency,
  );
  return Column(
    children: [
      if (chain.summary.isNotEmpty)
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Description'),
          subtitle: Text(chain.summary),
        ),
      // Note: Chain doesn't have timestamp field
      ListTile(
        leading: const Icon(Icons.fingerprint),
        title: const Text('Chain ID'),
        subtitle: SelectableText(chain.chainId),
      ),
      if (secondaryTile != null) secondaryTile,
    ],
  );
}

Widget _buildDeviceSummary(Device device) {
  return Card(
    margin: const EdgeInsets.all(8),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: device.status ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.devices,
                  size: 24,
                  color: device.status ? Colors.green[600] : Colors.red[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device ${device.deviceId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            device.status ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        device.status ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: device.status
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Device details
          if (device.hasTimestamp()) ...[
            _buildDeviceInfoRow(
              icon: Icons.schedule,
              label: 'Created',
              value: device.timestamp.toDateTime().toString().split('.')[0],
            ),
            const SizedBox(height: 8),
          ],

          if (device.hasHardwareInfo())
            _buildHardwareInfoSummary(device.hardwareInfo),
        ],
      ),
    ),
  );
}

Widget _buildDeviceInfoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      Expanded(
        child: Text(value),
      ),
    ],
  );
}

Widget _buildAddressSummary(Address address) {
  return ExpansionTile(
    leading: const Icon(Icons.location_on),
    title: const Text('Address'),
    subtitle: Text(_formatAddress(address)),
    children: [
      if (address.street.isNotEmpty)
        ListTile(
          title: const Text('Street'),
          subtitle: Text(address.street),
        ),
      if (address.hasCity() && address.city.isNotEmpty)
        ListTile(
          title: const Text('City'),
          subtitle: Text(address.city),
        ),
      if (address.hasCode() && address.code.isNotEmpty)
        ListTile(
          title: const Text('Postal Code'),
          subtitle: Text(address.code),
        ),
      if (address.hasCountry())
        ListTile(
          title: const Text('Country'),
          subtitle: Text(address.country.namel10n),
        ),
    ],
  );
}

Widget _buildPhoneSummary(Phone phone) {
  return ExpansionTile(
    leading: const Icon(Icons.phone),
    title: const Text('Phone'),
    subtitle: Text(
        phone.hasCountryCode() ? '+${phone.countryCode} ${phone.number}' : phone.number),
    children: [
      ListTile(
        title: const Text('Number'),
        subtitle: Text(phone.number),
      ),
      if (phone.hasCountryCode())
        ListTile(
          title: const Text('Country Code'),
          subtitle: Text('+${phone.countryCode}'),
        ),
    ],
  );
}

Widget _buildHardwareInfoSummary(dynamic hardwareInfo) {
  return ExpansionTile(
    leading: const Icon(Icons.computer),
    title: const Text('Hardware Info'),
    subtitle: const Text('Device specifications'),
    children: [
      if (hardwareInfo.hasName() && hardwareInfo.name.isNotEmpty)
        ListTile(
          title: const Text('Name'),
          subtitle: Text(hardwareInfo.name),
        ),
      if (hardwareInfo.hasBrand() && hardwareInfo.brand.isNotEmpty)
        ListTile(
          title: const Text('Brand'),
          subtitle: Text(hardwareInfo.brand),
        ),
      if (hardwareInfo.hasBaseOS() && hardwareInfo.baseOS.isNotEmpty)
        ListTile(
          title: const Text('Operating System'),
          subtitle: Text(hardwareInfo.baseOS),
        ),
      if (hardwareInfo.hasSerialNumber() &&
          hardwareInfo.serialNumber.isNotEmpty)
        ListTile(
          title: const Text('Serial Number'),
          subtitle: SelectableText(hardwareInfo.serialNumber),
        ),
    ],
  );
}
