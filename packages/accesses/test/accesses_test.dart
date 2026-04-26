import 'package:flutter_test/flutter_test.dart';
import 'package:accesses_weebi/accesses_weebi.dart';

void main() {
  test('accesses package exports are available', () {
    // Test that main exports are available
    expect(AccessProvider, isA<Type>());
    expect(AccessListWidget, isA<Type>());
    expect(UserAccessWidget, isA<Type>());
    expect(AccessRoutes, isA<Type>());
  });
}
