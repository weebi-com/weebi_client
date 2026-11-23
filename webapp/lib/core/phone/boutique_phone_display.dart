/// Dial digits from a country-picker code such as `+221`.
int? dialCodeToInt(String? dialCode) {
  final raw = dialCode?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  final dial = int.tryParse(raw);
  if (dial == null || dial <= 0) return null;
  return dial;
}

/// Display string Fence stores on the default boutique (`+33 612345678`).
String formatBoutiquePhone({int countryCode = 0, String number = ''}) {
  final digits = number.trim();
  if (digits.isEmpty) return '';
  if (countryCode <= 0) return digits;
  return '+$countryCode $digits';
}
