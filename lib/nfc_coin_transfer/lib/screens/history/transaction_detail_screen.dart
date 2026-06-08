import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';

/// Écran de détail d'une transaction NFC
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  static const Color _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(
      locale: 'fr_CM',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat("dd MMMM yyyy 'à' HH:mm", 'fr');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Détail transaction',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAmountCard(currencyFmt),
            const SizedBox(height: 16),
            _buildInfoCard(dateFmt),
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNoteCard(),
            ],
            if (transaction.nfcTagId != null) ...[
              const SizedBox(height: 16),
              _buildNfcCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(NumberFormat fmt) {
    final isSent = transaction.type == TransactionType.transfer ||
        transaction.type == TransactionType.withdraw;
    final color = isSent ? Colors.red.shade600 : Colors.green.shade600;
    final icon = isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSent
              ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)]
              : [const Color(0xFF6C63FF), const Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            fmt.format(transaction.amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _StatusBadge(status: transaction.status),
        ],
      ),
    );
  }

  Widget _buildInfoCard(DateFormat dateFmt) {
    return _Card(
      title: 'Informations',
      children: [
        _InfoRow(
          label: 'Expéditeur',
          value: transaction.senderName,
          icon: Icons.person_outline,
        ),
        _InfoRow(
          label: 'Destinataire',
          value: transaction.receiverName,
          icon: Icons.person_outline,
        ),
        _InfoRow(
          label: 'Type',
          value: transaction.type.label,
          icon: Icons.swap_horiz_rounded,
        ),
        _InfoRow(
          label: 'Date',
          value: dateFmt.format(transaction.timestamp),
          icon: Icons.calendar_today_outlined,
        ),
        _InfoRow(
          label: 'Référence',
          value: transaction.id.substring(0, 8).toUpperCase(),
          icon: Icons.tag,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildNoteCard() {
    return _Card(
      title: 'Note',
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            transaction.note!,
            style: const TextStyle(fontSize: 15, color: Color(0xFF444466)),
          ),
        ),
      ],
    );
  }

  Widget _buildNfcCard() {
    return _Card(
      title: 'Données NFC',
      children: [
        _InfoRow(
          label: 'Tag ID',
          value: transaction.nfcTagId!,
          icon: Icons.nfc_rounded,
          isLast: true,
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer cette transaction de l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context
          .read<TransactionProvider>()
          .deleteTransaction(transaction.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// ─── Widgets locaux ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9999BB),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9999BB)),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF888899))),
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F8)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case TransactionStatus.completed:
        bg = Colors.green.shade100;
        fg = Colors.green.shade700;
        break;
      case TransactionStatus.pending:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade700;
        break;
      case TransactionStatus.failed:
        bg = Colors.red.shade100;
        fg = Colors.red.shade700;
        break;
      case TransactionStatus.cancelled:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
