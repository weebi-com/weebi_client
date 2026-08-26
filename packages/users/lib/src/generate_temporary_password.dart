import 'dart:math';

/// Readable one-time password shown to the admin after user creation.
///
/// Omits ambiguous characters (0/O, 1/l/I) so it can be read aloud.
String generateTemporaryPassword({int length = 12, Random? random}) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  if (length < 8) {
    throw ArgumentError.value(length, 'length', 'must be at least 8');
  }
  final rng = random ?? Random.secure();
  return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
}
