
import 'package:flutter_test/flutter_test.dart';
import 'package:momo_wallet/models/wallet_transaction.dart';
import 'package:momo_wallet/services/wallet_service.dart';
import 'package:momo_wallet/states/wallet_state.dart';

void main() {
  group('WalletService', () {
    test('wallet starts with 10000 RWF', () {
      final wallet = WalletState();

      expect(wallet.balance, 10000);
      expect(wallet.totalIn, 2500);
      expect(wallet.totalOut, 2500);
      expect(wallet.lowestBalance, 10000);

      wallet.dispose();
    });

    test('rejects invalid phone prefixes', () {
      expect(
        WalletService.validateSend('0721234567', 100, 10000),
        isNotNull,
      );
    });

    test('rejects phone numbers with the wrong length', () {
      expect(
        WalletService.validateSend('078123456', 100, 10000),
        isNotNull,
      );
    });

    test('rejects sending less than 100 RWF', () {
      expect(
        WalletService.validateSend('0788123456', 50, 10000),
        isNotNull,
      );
    });

    test('rejects sending more than the balance', () {
      expect(
        WalletService.validateSend(
          '0788123456',
          1000000,
          10000,
        ),
        'Insufficient balance.',
      );
    });

    test('rejects cash-out amounts not divisible by 100', () {
      expect(
        WalletService.validateCashOut(250, 10000),
        isNotNull,
      );
    });

    test('calculates the exact cash-out notes', () {
      expect(
        WalletService.calculateDenominations(23700),
        {
          5000: 4,
          2000: 1,
          1000: 1,
          500: 1,
          100: 2,
        },
      );
    });

    test('rejects zero and negative amounts', () {
      expect(WalletService.validateAmount(0), isNotNull);
      expect(WalletService.validateAmount(-200), isNotNull);
    });

    test('prevents deletion that makes history negative', () {
      final transactions = [
        WalletTransaction(
          id: 'incoming',
          description: 'Received money',
          amount: 1000,
          type: TransactionType.incoming,
          createdAt: DateTime(2026, 10, 14),
        ),
        WalletTransaction(
          id: 'outgoing',
          description: 'Outgoing transfer',
          amount: 11000,
          type: TransactionType.outgoing,
          createdAt: DateTime(2026, 10, 15),
        ),
      ];

      expect(
        WalletService.canDeleteTransaction(
          transactions,
          'incoming',
        ),
        isFalse,
      );
    });
  });
}
