import 'package:flutter_test/flutter_test.dart';
import 'package:password/src/models/identity_card_model.dart';
import 'package:password/src/rust/models/identity_cards.dart';

void main() {
  group('IdentityCardModel', () {
    test('should create IdentityCardModel from json', () {
      final json = {
        'id': '1',
        'createdAt': 1234567890,
        'createdBy': 'user1',
        'updatedAt': 1234567891,
        'updatedBy': 'user1',
        'name': 'Test Identity Card',
        'note': 'Test note',
        'country': 'USA',
        'expiryDate': '2025-12-31',
        'identityCardNumber': 'ID123456',
        'identityCardType': 'Passport',
        'issueDate': '2020-01-01',
        'nameOnCard': 'John Doe',
        'state': 'CA',
        'isFavorite': true,
        'tags': ['tag1', 'tag2']
      };

      final identityCardModel = IdentityCardModel.fromJson(json);

      expect(identityCardModel.id, '1');
      expect(identityCardModel.createdAt, 1234567890);
      expect(identityCardModel.createdBy, 'user1');
      expect(identityCardModel.updatedAt, 1234567891);
      expect(identityCardModel.updatedBy, 'user1');
      expect(identityCardModel.name, 'Test Identity Card');
      expect(identityCardModel.note, 'Test note');
      expect(identityCardModel.country, 'USA');
      expect(identityCardModel.expiryDate, '2025-12-31');
      expect(identityCardModel.identityCardNumber, 'ID123456');
      expect(identityCardModel.identityCardType, 'Passport');
      expect(identityCardModel.issueDate, '2020-01-01');
      expect(identityCardModel.nameOnCard, 'John Doe');
      expect(identityCardModel.state, 'CA');
      expect(identityCardModel.isFavorite, true);
      expect(identityCardModel.tags, ['tag1', 'tag2']);
    });

    test('should create IdentityCardModel from IdentityCard', () {
      final identityCard = IdentityCard(
          id: '1',
          createdAt: 1234567890,
          createdBy: 'user1',
          updatedAt: 1234567891,
          updatedBy: 'user1',
          name: 'Test Identity Card',
          note: 'Test note',
          country: 'USA',
          expiryDate: '2025-12-31',
          identityCardNumber: 'ID123456',
          identityCardType: 'Passport',
          issueDate: '2020-01-01',
          nameOnCard: 'John Doe',
          state: 'CA',
          isFavorite: true,
          tags: 'tag1,tag2');

      final identityCardModel =
          IdentityCardModel.fromIdentityCard(identityCard);

      expect(identityCardModel.id, '1');
      expect(identityCardModel.createdAt, 1234567890);
      expect(identityCardModel.createdBy, 'user1');
      expect(identityCardModel.updatedAt, 1234567891);
      expect(identityCardModel.updatedBy, 'user1');
      expect(identityCardModel.name, 'Test Identity Card');
      expect(identityCardModel.note, 'Test note');
      expect(identityCardModel.country, 'USA');
      expect(identityCardModel.expiryDate, '2025-12-31');
      expect(identityCardModel.identityCardNumber, 'ID123456');
      expect(identityCardModel.identityCardType, 'Passport');
      expect(identityCardModel.issueDate, '2020-01-01');
      expect(identityCardModel.nameOnCard, 'John Doe');
      expect(identityCardModel.state, 'CA');
      expect(identityCardModel.isFavorite, true);
      expect(identityCardModel.tags, ['tag1', 'tag2']);
    });

    test('should handle null values correctly', () {
      final identityCard = IdentityCard(
        name: 'Test Identity Card',
        identityCardNumber: 'ID123456',
        nameOnCard: 'John Doe',
      );

      final identityCardModel =
          IdentityCardModel.fromIdentityCard(identityCard);

      expect(identityCardModel.id, null);
      expect(identityCardModel.createdAt, null);
      expect(identityCardModel.createdBy, null);
      expect(identityCardModel.updatedAt, null);
      expect(identityCardModel.updatedBy, null);
      expect(identityCardModel.note, null);
      expect(identityCardModel.country, null);
      expect(identityCardModel.expiryDate, null);
      expect(identityCardModel.identityCardType, null);
      expect(identityCardModel.issueDate, null);
      expect(identityCardModel.state, null);
      expect(identityCardModel.isFavorite, null);
      expect(identityCardModel.tags, []);
    });

    test('should create minimal IdentityCardModel with required fields only',
        () {
      final identityCardModel = IdentityCardModel(
        name: 'Test Identity Card',
        identityCardNumber: 'ID123456',
        nameOnCard: 'John Doe',
      );

      expect(identityCardModel.name, 'Test Identity Card');
      expect(identityCardModel.identityCardNumber, 'ID123456');
      expect(identityCardModel.nameOnCard, 'John Doe');
      expect(identityCardModel.id, null);
      expect(identityCardModel.createdAt, null);
      expect(identityCardModel.createdBy, null);
      expect(identityCardModel.updatedAt, null);
      expect(identityCardModel.updatedBy, null);
      expect(identityCardModel.note, null);
      expect(identityCardModel.country, null);
      expect(identityCardModel.expiryDate, null);
      expect(identityCardModel.identityCardType, null);
      expect(identityCardModel.issueDate, null);
      expect(identityCardModel.state, null);
      expect(identityCardModel.isFavorite, null);
      expect(identityCardModel.tags, null);
    });
  });
}
