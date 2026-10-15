
import '../models/wallet_transaction.dart';

class WalletService {
  static const int startingBalance = 10000;

  static const List<int> denominations = [
    5000,
    2000,
    1000,
    500,
    100,
  ];

  static String? validateAmount(int? amount) {
    if (amount == null) {
      return 'Enter a valid whole-number amount.';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0.';
    }

    return null;
  }

  static String? validateReceive(
      int? amount,
      String description,
      ) {
    final amountError = validateAmount(amount);

    if (amountError != null) {
      return amountError;
    }

    if (description.trim().isEmpty) {
      return 'Description cannot be empty.';
    }

    return null;
  }

  static String? validateSend(
      String phone,
      int? amount,
      int currentBalance,
      ) {
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Phone number must contain exactly 10 digits.';
    }

    if (!phone.startsWith('078') &&
        !phone.startsWith('079')) {
      return 'Phone number must start with 078 or 079.';
    }

    final amountError = validateAmount(amount);

    if (amountError != null) {
      return amountError;
    }

    if (amount! < 100) {
      return 'Send amount must be at least 100 RWF.';
    }

    if (amount > currentBalance) {
      return 'Insufficient balance.';
    }

    return null;
  }

  static String? validateCashOut(
      int? amount,
      int currentBalance,
      ) {
    final amountError = validateAmount(amount);

    if (amountError != null) {
      return amountError;
    }

    if (amount! % 100 != 0) {
      return 'Cash-out amount must be a multiple of 100 RWF.';
    }

    if (amount > currentBalance) {
      return 'Insufficient balance.';
    }

    return null;
  }

  static Map<int, int> calculateDenominations(
      int amount,
      ) {
    final notes = <int, int>{};
    var remaining = amount;

    for (final denomination in denominations) {
      final count = remaining ~/ denomination;

      if (count > 0) {
        notes[denomination] = count;
        remaining %= denomination;
      }
    }

    return notes;
  }

  static int calculateBalance(
      List<WalletTransaction> transactions,
      ) {
    var balance = startingBalance;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.incoming) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    return balance;
  }

  static int calculateTotalIn(
      List<WalletTransaction> transactions,
      ) {
    return transactions
        .where((t) => t.type == TransactionType.incoming)
        .fold(0, (total, t) => total + t.amount);
  }

  static int calculateTotalOut(
      List<WalletTransaction> transactions,
      ) {
    return transactions
        .where((t) => t.type == TransactionType.outgoing)
        .fold(0, (total, t) => total + t.amount);
  }

  static int calculateLowestBalance(
      List<WalletTransaction> transactions,
      ) {
    var balance = startingBalance;
    var lowestBalance = balance;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.incoming) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }

      if (balance < lowestBalance) {
        lowestBalance = balance;
      }
    }

    return lowestBalance;
  }

  static bool canDeleteTransaction(
      List<WalletTransaction> transactions,
      String transactionId,
      ) {
    final remaining = transactions
        .where((t) => t.id != transactionId)
        .toList();

    var balance = startingBalance;

    for (final transaction in remaining) {
      if (transaction.type == TransactionType.incoming) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }

      if (balance < 0) {
        return false;
      }
    }

    return true;
  }
}
