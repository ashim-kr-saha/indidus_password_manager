import 'package:flutter_test/flutter_test.dart';
import 'package:password/src/models/financial_card_model.dart';
import 'package:password/src/rust/models/financial_cards.dart';

void main() {
  group('FinancialCardModel', () {
    test('should create FinancialCardModel from json', () {
      final json = {
        'id': '1',
        'createdAt': 1234567890,
        'createdBy': 'user1',
        'updatedAt': 1234567891,
        'updatedBy': 'user1',
        'cardHolderName': 'John Doe',
        'cardNumber': '4111111111111111',
        'cardProviderName': 'Visa',
        'cardType': 'Credit',
        'cvv': '123',
        'expiryDate': '12/25',
        'issueDate': '01/20',
        'name': 'Test Financial Card',
        'note': 'Test note',
        'pin': '1234',
        'isFavorite': true,
        'tags': ['tag1', 'tag2']
      };

      final financialCardModel = FinancialCardModel.fromJson(json);

      expect(financialCardModel.id, '1');
      expect(financialCardModel.createdAt, 1234567890);
      expect(financialCardModel.createdBy, 'user1');
      expect(financialCardModel.updatedAt, 1234567891);
      expect(financialCardModel.updatedBy, 'user1');
      expect(financialCardModel.cardHolderName, 'John Doe');
      expect(financialCardModel.cardNumber, '4111111111111111');
      expect(financialCardModel.cardProviderName, 'Visa');
      expect(financialCardModel.cardType, 'Credit');
      expect(financialCardModel.cvv, '123');
      expect(financialCardModel.expiryDate, '12/25');
      expect(financialCardModel.issueDate, '01/20');
      expect(financialCardModel.name, 'Test Financial Card');
      expect(financialCardModel.note, 'Test note');
      expect(financialCardModel.pin, '1234');
      expect(financialCardModel.isFavorite, true);
      expect(financialCardModel.tags, ['tag1', 'tag2']);
    });

    test('should create FinancialCardModel from FinancialCard', () {
      final financialCard = FinancialCard(
          id: '1',
          createdAt: 1234567890,
          createdBy: 'user1',
          updatedAt: 1234567891,
          updatedBy: 'user1',
          cardHolderName: 'John Doe',
          cardNumber: '4111111111111111',
          cardProviderName: 'Visa',
          cardType: 'Credit',
          cvv: '123',
          expiryDate: '12/25',
          issueDate: '01/20',
          name: 'Test Financial Card',
          note: 'Test note',
          pin: '1234',
          isFavorite: true,
          tags: 'tag1,tag2');

      final financialCardModel =
          FinancialCardModel.fromFinancialCard(financialCard);

      expect(financialCardModel.id, '1');
      expect(financialCardModel.createdAt, 1234567890);
      expect(financialCardModel.createdBy, 'user1');
      expect(financialCardModel.updatedAt, 1234567891);
      expect(financialCardModel.updatedBy, 'user1');
      expect(financialCardModel.cardHolderName, 'John Doe');
      expect(financialCardModel.cardNumber, '4111111111111111');
      expect(financialCardModel.cardProviderName, 'Visa');
      expect(financialCardModel.cardType, 'Credit');
      expect(financialCardModel.cvv, '123');
      expect(financialCardModel.expiryDate, '12/25');
      expect(financialCardModel.issueDate, '01/20');
      expect(financialCardModel.name, 'Test Financial Card');
      expect(financialCardModel.note, 'Test note');
      expect(financialCardModel.pin, '1234');
      expect(financialCardModel.isFavorite, true);
      expect(financialCardModel.tags, ['tag1', 'tag2']);
    });

    test('should handle null values correctly', () {
      final financialCard = FinancialCard(
        cardHolderName: 'John Doe',
        cardNumber: '4111111111111111',
        name: 'Test Financial Card',
      );

      final financialCardModel =
          FinancialCardModel.fromFinancialCard(financialCard);

      expect(financialCardModel.id, null);
      expect(financialCardModel.createdAt, null);
      expect(financialCardModel.createdBy, null);
      expect(financialCardModel.updatedAt, null);
      expect(financialCardModel.updatedBy, null);
      expect(financialCardModel.cardProviderName, null);
      expect(financialCardModel.cardType, null);
      expect(financialCardModel.cvv, null);
      expect(financialCardModel.expiryDate, null);
      expect(financialCardModel.issueDate, null);
      expect(financialCardModel.note, null);
      expect(financialCardModel.pin, null);
      expect(financialCardModel.isFavorite, null);
      expect(financialCardModel.tags, []);
    });

    test('should create minimal FinancialCardModel with required fields only',
        () {
      final financialCardModel = FinancialCardModel(
        cardHolderName: 'John Doe',
        cardNumber: '4111111111111111',
        name: 'Test Financial Card',
      );

      expect(financialCardModel.cardHolderName, 'John Doe');
      expect(financialCardModel.cardNumber, '4111111111111111');
      expect(financialCardModel.name, 'Test Financial Card');
      expect(financialCardModel.id, null);
      expect(financialCardModel.createdAt, null);
      expect(financialCardModel.createdBy, null);
      expect(financialCardModel.updatedAt, null);
      expect(financialCardModel.updatedBy, null);
      expect(financialCardModel.cardProviderName, null);
      expect(financialCardModel.cardType, null);
      expect(financialCardModel.cvv, null);
      expect(financialCardModel.expiryDate, null);
      expect(financialCardModel.issueDate, null);
      expect(financialCardModel.note, null);
      expect(financialCardModel.pin, null);
      expect(financialCardModel.isFavorite, null);
      expect(financialCardModel.tags, null);
    });
  });
}
