
import 'package:flutter/foundation.dart';

import '../models/wallet_transaction.dart';
import '../services/wallet_service.dart';

class WalletState extends ChangeNotifier {
  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'sample-1',
      description: 'Received from Alice',
      amount: 2500,
      type: TransactionType.incoming,
      createdAt: DateTime(2026, 10, 14, 9, 0),
    ),
    WalletTransaction(
      id: 'sample-2',
      description: 'Sent to 0788123456',
      amount: 1500,
      type: TransactionType.outgoing,
      createdAt: DateTime(2026, 10, 14, 10, 0),
    ),
    WalletTransaction(
      id: 'sample-3',
      description: 'Cash out',
      amount: 1000,
      type: TransactionType.outgoing,
      createdAt: DateTime(2026, 10, 15, 8, 0),
    ),
  ];

  List<WalletTransaction> get transactions =>
      List.unmodifiable(_transactions);

  int get balance =>
      WalletService.calculateBalance(_transactions);

  int get totalIn =>
      WalletService.calculateTotalIn(_transactions);

  int get totalOut =>
      WalletService.calculateTotalOut(_transactions);

  int get lowestBalance =>
      WalletService.calculateLowestBalance(_transactions);

  void _addTransaction({
    required String description,
    required int amount,
    required TransactionType type,
  }) {
    _transactions.add(
      WalletTransaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        description: description,
        amount: amount,
        type: type,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  String? receiveMoney(int? amount, String description) {
    final error = WalletService.validateReceive(
      amount,
      description,
    );

    if (error != null) {
      return error;
    }

    _addTransaction(
      description: description.trim(),
      amount: amount!,
      type: TransactionType.incoming,
    );

    return null;
  }

  String? sendMoney(String phone, int? amount) {
    final error = WalletService.validateSend(
      phone,
      amount,
      balance,
    );

    if (error != null) {
      return error;
    }

    _addTransaction(
      description: 'Sent to $phone',
      amount: amount!,
      type: TransactionType.outgoing,
    );

    return null;
  }

  String? cashOut(int? amount) {
    final error = WalletService.validateCashOut(
      amount,
      balance,
    );

    if (error != null) {
      return error;
    }

    _addTransaction(
      description: 'Cash out',
      amount: amount!,
      type: TransactionType.outgoing,
    );

    return null;
  }

  String? deleteTransaction(String transactionId) {
    final exists = _transactions.any(
          (t) => t.id == transactionId,
    );

    if (!exists) {
      return 'Transaction not found.';
    }

    if (!WalletService.canDeleteTransaction(
      _transactions,
      transactionId,
    )) {
      return 'Cannot delete: historical balance would go below 0.';
    }

    _transactions.removeWhere(
          (t) => t.id == transactionId,
    );

    notifyListeners();
    return null;
  }
}
