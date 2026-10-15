
enum TransactionType {
  incoming,
  outgoing,
}

class WalletTransaction {
  final String id;
  final String description;
  final int amount;
  final TransactionType type;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  bool get isIncoming => type == TransactionType.incoming;
}
