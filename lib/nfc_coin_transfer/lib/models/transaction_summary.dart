/// Résumé statistique des transactions pour un utilisateur
class TransactionSummary {
  final double totalSent;
  final double totalReceived;
  final int sentCount;
  final int receivedCount;
  final int totalCount;
  final double netBalance;
  final DateTime? lastTransactionDate;

  const TransactionSummary({
    required this.totalSent,
    required this.totalReceived,
    required this.sentCount,
    required this.receivedCount,
    required this.totalCount,
    required this.netBalance,
    this.lastTransactionDate,
  });

  factory TransactionSummary.empty() {
    return const TransactionSummary(
      totalSent: 0,
      totalReceived: 0,
      sentCount: 0,
      receivedCount: 0,
      totalCount: 0,
      netBalance: 0,
    );
  }

  @override
  String toString() =>
      'TransactionSummary(sent: $totalSent, received: $totalReceived, total: $totalCount)';
}
