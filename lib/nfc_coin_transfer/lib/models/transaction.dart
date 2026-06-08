/// Modèle représentant une transaction NFC entre deux utilisateurs
class Transaction {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? note;
  final String? nfcTagId;

  const Transaction({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.note,
    this.nfcTagId,
  });

  /// Crée une Transaction depuis un Map (JSON/SQLite)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.transfer,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      note: map['note'] as String?,
      nfcTagId: map['nfcTagId'] as String?,
    );
  }

  /// Convertit la Transaction en Map pour stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'note': note,
      'nfcTagId': nfcTagId,
    };
  }

  /// Retourne true si l'utilisateur courant est l'expéditeur
  bool isSent(String currentUserId) => senderId == currentUserId;

  /// Retourne true si l'utilisateur courant est le destinataire
  bool isReceived(String currentUserId) => receiverId == currentUserId;

  Transaction copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? timestamp,
    String? note,
    String? nfcTagId,
  }) {
    return Transaction(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      nfcTagId: nfcTagId ?? this.nfcTagId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, type: ${type.name}, status: ${status.name})';
}

enum TransactionType {
  transfer,  // Transfert P2P classique
  receive,   // Réception de fonds
  topUp,     // Rechargement du solde
  withdraw,  // Retrait
}

enum TransactionStatus {
  pending,   // En attente de confirmation NFC
  completed, // Confirmée et finalisée
  failed,    // Échec (NFC ou réseau)
  cancelled, // Annulée par l'utilisateur
}

/// Extension utilitaires pour TransactionType
extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.receive:
        return 'Réception';
      case TransactionType.topUp:
        return 'Rechargement';
      case TransactionType.withdraw:
        return 'Retrait';
    }
  }
}

/// Extension utilitaires pour TransactionStatus
extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.completed:
        return 'Complétée';
      case TransactionStatus.failed:
        return 'Échouée';
      case TransactionStatus.cancelled:
        return 'Annulée';
    }
  }
}
