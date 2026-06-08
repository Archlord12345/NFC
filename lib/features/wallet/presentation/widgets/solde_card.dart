import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/wallet.dart';

/// Carte affichant le solde du wallet.
///
/// Utilisée sur la [WalletPage] en position proéminente.
/// Design : gradient navy avec accent teal.
class SoldeCard extends StatelessWidget {
  final Wallet wallet;

  const SoldeCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(100),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Actif',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Montant ───────────────────────────────────────────────────────
          Text(
            _formatSolde(wallet.solde, wallet.devise),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            wallet.devise == 'XAF' ? 'Francs CFA' : 'Euros',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 24),

          // ── Pied de carte ─────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.credit_card_rounded,
                  color: Colors.white38, size: 18),
              const SizedBox(width: 8),
              Text(
                '•••• •••• •••• ${wallet.id.substring(wallet.id.length - 4).toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSolde(double solde, String devise) {
    if (devise == 'XAF') {
      final formatted =
          NumberFormat('#,###', 'fr_FR').format(solde).replaceAll(',', ' ');
      return '$formatted FCFA';
    }
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(solde);
  }
}
