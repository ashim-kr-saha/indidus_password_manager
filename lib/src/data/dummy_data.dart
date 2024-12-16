import '../rust/models/financial_cards.dart';
import '../rust/models/identity_cards.dart';
import '../rust/models/logins.dart';
import '../rust/models/notes.dart';
import '../rust/models/tags.dart';

class DummyData {
  static List<FinancialCard> financialCards({
    required Tag bankingTag,
    required Tag workTag,
    required Tag personalTag,
  }) {
    return [
      FinancialCard(
        name: 'Master Card',
        note:
            'This is a dummy master card, you can change it or delete it as you want',
        cardHolderName: 'John Doe',
        cardNumber: '1234567890123456',
        cardProviderName: 'MasterCard',
        cardType: 'Credit',
        cvv: '123',
        expiryDate: '2024-02-20',
        issueDate: '2024-02-20',
        pin: '1234',
        isFavorite: false,
        tags: [bankingTag.id!, workTag.id!].join(','),
      ),
      FinancialCard(
        name: 'Visa Card',
        note:
            'This is a dummy visa card, you can change it or delete it as you want',
        cardHolderName: 'Jane Doe',
        cardNumber: '1234567890123457',
        cardProviderName: 'Visa',
        cardType: 'Credit',
        cvv: '456',
        expiryDate: '2025-02-20',
        issueDate: '2024-02-20',
        pin: '4567',
        isFavorite: false,
        tags: [personalTag.id!, workTag.id!].join(','),
      ),
    ];
  }

  static List<Login> logins({
    required Tag personalTag,
    required Tag workTag,
    required Tag travelTag,
    required Tag socialTag,
    required Tag shoppingTag,
    required Tag entertainmentTag,
  }) {
    return [
      Login(
        username: 'john.doe',
        name: 'Gmail Login',
        note:
            'This is a dummy login for gmail, you can change it or delete it as you want',
        url: 'https://mail.google.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [personalTag.id!].join(','),
      ),
      Login(
        username: 'peter.doe',
        name: 'Github Login',
        note:
            'This is a dummy login for github, you can change it or delete it as you want',
        url: 'https://github.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: true,
        tags: [workTag.id!].join(','),
      ),
      Login(
        username: 'john.doe',
        name: 'Twitter Login',
        note:
            'This is a dummy login for twitter, you can change it or delete it as you want',
        url: 'https://twitter.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [socialTag.id!].join(','),
      ),
      Login(
        username: 'john.doe',
        name: 'Facebook Login',
        note:
            'This is a dummy login for facebook, you can change it or delete it as you want',
        url: 'https://www.facebook.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [socialTag.id!].join(','),
      ),
      Login(
        username: 'john.doe',
        name: 'Linkedin Login',
        note:
            'This is a dummy login for linkedin, you can change it or delete it as you want',
        url: 'https://www.linkedin.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: true,
        tags: [socialTag.id!, workTag.id!].join(','),
      ),
      Login(
        username: 'john.doe',
        name: 'Amazon Login',
        note:
            'This is a dummy login for amazon, you can change it or delete it as you want',
        url: 'https://www.amazon.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [personalTag.id!, shoppingTag.id!].join(','),
      ),
      Login(
        username: 'john.doe',
        name: 'Netflix Login',
        note:
            'This is a dummy login for netflix, you can change it or delete it as you want',
        url: 'https://www.netflix.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [personalTag.id!, entertainmentTag.id!].join(','),
      ),
      Login(
        name: 'Instagram Login',
        username: 'john.doe',
        note:
            'This is a dummy login for instagram, you can change it or delete it as you want',
        url: 'https://www.instagram.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [personalTag.id!, socialTag.id!].join(','),
      ),
      Login(
        name: 'Pinterest Login',
        username: 'john.doe',
        note:
            'This is a dummy login for pinterest, you can change it or delete it as you want',
        url: 'https://www.pinterest.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: false,
        tags: [personalTag.id!, socialTag.id!].join(','),
      ),
      Login(
        name: 'ChatGPT Login',
        username: 'john.doe',
        note:
            'This is a dummy login for chatgpt, you can change it or delete it as you want',
        url: 'https://www.chatgpt.com',
        password: 'my_password',
        passwordHint: 'my_password_hint',
        isFavorite: true,
        tags: [personalTag.id!, workTag.id!].join(','),
        apiKeys: '[{"name": "api_key_name", "value": "api_key_value"}]',
      ),
    ];
  }

  static List<Note> notes({
    required Tag personalTag,
    required Tag workTag,
  }) {
    return [
      Note(
        name: 'Note 1',
        note:
            'This is a dummy note, you can change it or delete it as you want',
        isFavorite: false,
        tags: [personalTag.id!].join(','),
      ),
      Note(
        name: 'Note 2',
        note:
            'This is a dummy note, you can change it or delete it as you want',
        isFavorite: true,
        tags: [personalTag.id!, workTag.id!].join(','),
      ),
    ];
  }

  static List<IdentityCard> identityCards({
    required Tag personalTag,
    required Tag workTag,
  }) {
    return [
      IdentityCard(
        name: 'Passport',
        nameOnCard: 'John Doe',
        identityCardNumber: '1234567890',
        issueDate: '2024-02-20',
        expiryDate: '2024-02-20',
        isFavorite: false,
        tags: [personalTag.id!].join(','),
      ),
      IdentityCard(
        name: 'Driver License',
        nameOnCard: 'John Doe',
        identityCardNumber: '1234567890',
        issueDate: '2024-02-20',
        expiryDate: '2024-02-20',
        isFavorite: false,
        tags: [personalTag.id!, workTag.id!].join(','),
      ),
      IdentityCard(
        name: 'Identity Card',
        nameOnCard: 'John Doe',
        identityCardNumber: '1234567890',
        issueDate: '2024-02-20',
        expiryDate: '2024-02-20',
        isFavorite: true,
        tags: [personalTag.id!].join(','),
      ),
    ];
  }
}
