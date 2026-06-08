import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Page de reçu numérique après un transfert NFC réussi.
class NfcReceiptPage extends StatelessWidget {
  const NfcReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = ModalRoute.of(context)?.settings.arguments as String? ?? '0.00';

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('FINTECH'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icône succès ──
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.check_rounded, size: 48, color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              Text('Transfer Successful',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Your transaction has been processed securely.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white54)),
              const SizedBox(height: 32),

              // ── Carte reçu ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(children: [
                  Text('\$$amount',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _ReceiptRow(label: 'FROM', value: 'My Wallet'),
                  _ReceiptRow(label: 'TO', value: 'iPhone de Marc'),
                  _ReceiptRow(label: 'DATE', value: _currentDate()),
                  _ReceiptRow(label: 'STATUS', value: '● Completed',
                      valueColor: AppColors.accent),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Boutons ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download Receipt'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (_) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _currentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ReceiptRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500)),
          Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: valueColor ?? AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
