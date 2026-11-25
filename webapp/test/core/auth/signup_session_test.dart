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

  group('clientAccessTokenForMode', () {
    test('BFF mode always drops leaked JWT access tokens', () {
      expect(
        clientAccessTokenForMode(
          isBffMode: true,
          accessToken: 'eyJhbGciOiJIUzI1NiJ9.leaked.sig',
        ),
        isNull,
      );
      expect(
        clientAccessTokenForMode(isBffMode: true, accessToken: ''),
        isNull,
      );
    });

    test('JWT mode keeps non-empty access tokens only', () {
      expect(
        clientAccessTokenForMode(isBffMode: false, accessToken: 'jwt-123'),
        'jwt-123',
      );
      expect(
        clientAccessTokenForMode(isBffMode: false, accessToken: ''),
        isNull,
      );
      expect(
        clientAccessTokenForMode(isBffMode: false, accessToken: null),
        isNull,
      );
    });
  });

  group('validateOptionalPhoneDigits', () {
    test('empty or whitespace phone is valid (phone is optional)', () {
      expect(
        validateOptionalPhoneDigits('', expectedLength: 9),
        OptionalPhoneValidation.valid,
      );
      expect(
        validateOptionalPhoneDigits('   ', expectedLength: 9),
        OptionalPhoneValidation.valid,
      );
      expect(
        validateOptionalPhoneDigits(null, expectedLength: 9),
        OptionalPhoneValidation.valid,
      );
    });

    test('non-empty phone still checks digits and expected length', () {
      expect(
        validateOptionalPhoneDigits('771234567', expectedLength: 9),
        OptionalPhoneValidation.valid,
      );
      expect(
        validateOptionalPhoneDigits('7712', expectedLength: 9),
        OptionalPhoneValidation.wrongLength,
      );
      expect(
        validateOptionalPhoneDigits('abc', expectedLength: 9),
        OptionalPhoneValidation.notDigits,
      );
    });
  });
}
