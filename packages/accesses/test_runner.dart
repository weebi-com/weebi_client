// Run with: dart run test_runner.dart
// 
// This script demonstrates how to run the tests and generate mocks

// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  print('🧪 Running Accesses Package Tests');
  print('================================\n');

  // Step 1: Generate mocks
  print('📋 Step 1: Generating mocks...');
  final mockResult = await Process.run('dart', ['run', 'build_runner', 'build']);
  
  if (mockResult.exitCode == 0) {
    print('✅ Mocks generated successfully');
  } else {
    print('❌ Failed to generate mocks:');
    print(mockResult.stderr);
    return;
  }

  // Step 2: Run tests
  print('\n🚀 Step 2: Running tests...');
  final testResult = await Process.run('flutter', ['test']);
  
  if (testResult.exitCode == 0) {
    print('✅ All tests passed!');
    print(testResult.stdout);
  } else {
    print('❌ Some tests failed:');
    print(testResult.stderr);
    print(testResult.stdout);
  }

  print('\n📊 Test Summary:');
  print('- AccessProvider: State management and business logic');
  print('- AccessRoutes: Navigation and route generation');
  print('- AccessListWidget: User list display and search');
  print('- UserAccessWidget: Individual user access management');
  
  print('\n🔧 To run tests manually:');
  print('1. dart run build_runner build (generate mocks)');
  print('2. flutter test (run all tests)');
  print('3. flutter test test/access_provider_test.dart (specific test)');
}
