// Import the test package
import 'package:test/test.dart';
import 'package:myapp/utils.dart'; // Assuming the sanitizeLikeString function is in utils.dart

void main() {
  const disallowed = ',./;[]!@#\$%^&*()_-=+~';

  group('Test SQLite Sanitize like string with latin and non-latin characters', () {
    test('test (latin)', () {
      expect(sanitizeLikeString('test123'), 'test123');
      expect(sanitizeLikeString('test123$disallowed'), 'test123${'_' * disallowed.length}');
    });

    test('test (arabic)', () {
      expect(sanitizeLikeString('اختبار123'), 'اختبار123');
      expect(sanitizeLikeString('اختبار123$disallowed'), 'اختبار123${'_' * disallowed.length}');
    });

    test('test (greek)', () {
      expect(sanitizeLikeString('δοκιμή123'), 'δοκιμή123');
      expect(sanitizeLikeString('δοκιμή123$disallowed'), 'δοκιμή123${'_' * disallowed.length}');
    });

    test('test (hebrew)', () {
      expect(sanitizeLikeString('חשבון123'), 'חשבון123');
      expect(sanitizeLikeString('חשבון123$disallowed'), 'חשבון123${'_' * disallowed.length}');
    });

    test('test (russian)', () {
      expect(sanitizeLikeString('тест123'), 'тест123');
      expect(sanitizeLikeString('тест123$disallowed'), 'тест123${'_' * disallowed.length}');
    });

    test('test (chinese trad)', () {
      expect(sanitizeLikeString('測試123'), '測試123');
      expect(sanitizeLikeString('測試123$disallowed'), '測試123${'_' * disallowed.length}');
    });

    test('test (japanese)', () {
      expect(sanitizeLikeString('テスト123'), 'テスト123');
      expect(sanitizeLikeString('テスト123$disallowed'), 'テスト123${'_' * disallowed.length}');
    });
  });
}
