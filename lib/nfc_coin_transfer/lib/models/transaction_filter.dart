import 'transaction.dart';

/// Modèle de filtres pour l'historique des transactions
class TransactionFilter {
  final TransactionType? type;
  final TransactionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;

  const TransactionFilter({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
  });

  /// Retourne true si aucun filtre n'est appliqué
  bool get isEmpty =>
      type == null &&
      status == null &&
      startDate == null &&
      endDate == null &&
      minAmount == null &&
      maxAmount == null &&
      (searchQuery == null || searchQuery!.isEmpty);

  /// Nombre de filtres actifs
  int get activeCount {
    int count = 0;
    if (type != null) count++;
    if (status != null) count++;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    return count;
  }

  TransactionFilter copyWith({
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    bool clearType = false,
    bool clearStatus = false,
    bool clearDates = false,
    bool clearAmounts = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      minAmount: clearAmounts ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmounts ? null : (maxAmount ?? this.maxAmount),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  String toString() =>
      'TransactionFilter(type: $type, status: $status, activeCount: $activeCount)';
}
