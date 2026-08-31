import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/core/auth/signup_session.dart';

void main() {
  group('signupAuthSucceeded', () {
    test('BFF requires a sessionId, not a JWT', () {
      expect(
        signupAuthSucceeded(
          isBffMode: true,
          accessToken: '',
          sessionId: 'sess-1',
        ),
        isTrue,
      );
      expect(
        signupAuthSucceeded(
          isBffMode: true,
          accessToken: 'jwt',
          sessionId: '',
        ),
        isFalse,
      );
    });

    test('JWT mode requires an access token', () {
      expect(
        signupAuthSucceeded(
          isBffMode: false,
          accessToken: 'jwt',
          sessionId: '',
        ),
        isTrue,
      );
      expect(
        signupAuthSucceeded(
          isBffMode: false,
          accessToken: '',
          sessionId: 'sess-1',
        ),
        isFalse,
      );
    });
  });

  group('shouldCreateFirmAfterSignup', () {
    test('boss CREATED must create a firm', () {
      expect(shouldCreateFirmAfterSignup('CREATED'), isTrue);
    });

    test('invited UPDATED must not create a firm', () {
      expect(shouldCreateFirmAfterSignup('UPDATED'), isFalse);
    });
  });
}
