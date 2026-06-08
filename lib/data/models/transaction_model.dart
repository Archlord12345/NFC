class TransactionModel {
  final String id;
  final double amount;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;
  final String status; // 'pending', 'success', 'failed'

  TransactionModel({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    required this.status,
  });

  // Pour ton collègue du Rôle 5 (Data & Historique) pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: map['status'] ?? '',
    );
  }
}