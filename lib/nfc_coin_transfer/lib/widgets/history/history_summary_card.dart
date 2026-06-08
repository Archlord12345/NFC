import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_summary.dart';

/// Carte de résumé statistique affichée en haut de l'historique
class HistorySummaryCard extends StatelessWidget {
  final TransactionSummary summary;

  const HistorySummaryCard({super.key, required this.summary});

  static final _fmt = NumberFormat.currency(
    locale: 'fr_CM',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatColumn(
                label: 'Envoyé',
                value: _fmt.format(summary.totalSent),
                count: '${summary.sentCount} transac.',
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.red.shade200,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.2),
              ),
              _StatColumn(
                label: 'Reçu',
                value: _fmt.format(summary.totalReceived),
                count: '${summary.receivedCount} transac.',
                icon: Icons.arrow_downward_rounded,
                iconColor: Colors.green.shade200,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solde net',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${summary.netBalance >= 0 ? '+' : ''}${_fmt.format(summary.netBalance)}',
                  style: TextStyle(
                    color: summary.netBalance >= 0
                        ? Colors.greenAccent.shade100
                        : Colors.red.shade200,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String count;
  final IconData icon;
  final Color iconColor;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
