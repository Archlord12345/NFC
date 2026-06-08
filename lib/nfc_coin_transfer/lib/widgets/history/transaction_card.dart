import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';

/// Carte représentant une transaction dans la liste de l'historique
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currentUserId,
    this.onTap,
    this.onDelete,
  });

  static final _currencyFmt = NumberFormat.currency(
    locale: 'fr_CM',
    symbol: 'FCFA',
    decimalDigits: 0,
  );
  static final _dateFmt = DateFormat('dd MMM · HH:mm', 'fr');

  bool get _isSent => transaction.isSent(currentUserId);

  String get _counterpartName =>
      _isSent ? transaction.receiverName : transaction.senderName;

  Color get _amountColor =>
      _isSent ? Colors.red.shade600 : Colors.green.shade600;

  String get _amountPrefix => _isSent ? '- ' : '+ ';

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text('Supprimer',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await _confirmDelete(context);
      },
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              _buildAmount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _isSent
            ? Colors.red.shade50
            : const Color(0xFF6C63FF).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: _isSent ? Colors.red.shade600 : const Color(0xFF6C63FF),
        size: 22,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _counterpartName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _StatusDot(status: transaction.status),
            const SizedBox(width: 6),
            Text(
              _dateFmt.format(transaction.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        if (transaction.note != null && transaction.note!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            transaction.note!,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$_amountPrefix${_currencyFmt.format(transaction.amount)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _amountColor,
          ),
        ),
        const SizedBox(height: 4),
        Icon(Icons.nfc_rounded, size: 14, color: Colors.grey.shade400),
      ],
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Retirer cette transaction de l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Indicateur coloré de statut
class _StatusDot extends StatelessWidget {
  final TransactionStatus status;

  const _StatusDot({required this.status});

  Color get _color {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green.shade500;
      case TransactionStatus.pending:
        return Colors.orange.shade500;
      case TransactionStatus.failed:
        return Colors.red.shade500;
      case TransactionStatus.cancelled:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}
