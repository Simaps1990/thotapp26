import 'package:flutter_test/flutter_test.dart';
import 'package:thot/utils/document_hash.dart';

void main() {
  group('DocumentHash', () {
    test('same input produces same hash', () {
      final h1 = DocumentHash.compute({'a': 1, 'b': 'hello'});
      final h2 = DocumentHash.compute({'a': 1, 'b': 'hello'});
      expect(h1, equals(h2));
    });

    test('different values produce different hashes', () {
      final h1 = DocumentHash.compute({'a': 1});
      final h2 = DocumentHash.compute({'a': 2});
      expect(h1, isNot(equals(h2)));
    });

    test('key ordering does not affect hash', () {
      final h1 = DocumentHash.compute({'a': 1, 'b': 2});
      final h2 = DocumentHash.compute({'b': 2, 'a': 1});
      expect(h1, equals(h2));
    });

    test('nested maps are handled', () {
      final h1 = DocumentHash.compute({'nested': {'x': 1}});
      final h2 = DocumentHash.compute({'nested': {'x': 1}});
      expect(h1, equals(h2));
    });

    test('returns non-empty string', () {
      expect(DocumentHash.compute({'a': 1}), isNotEmpty);
    });
  });
}
