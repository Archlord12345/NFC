import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';

/// Tuile représentant une transaction dans la liste de l'historique.
///
/// Affiche : icône directionnelle, type, date, montant (coloré selon sens).
class TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;

  /// ID du wallet courant — utilisé pour déterminer si c'est une entrée/sortie.
  final String currentWalletId;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currentWalletId,
  });

  @override
  Widget build(BuildContext context) {
    final isEntree = transaction.estEntree(currentWalletId);
    final isRecharge = transaction.type == 'RECHARGE';
    final isEchoue = transaction.statut == 2;

    final couleurMontant = isEchoue
        ? AppColors.textSecondaryLight
        : isEntree
            ? AppColors.success
            : AppColors.error;

    final icone = _buildIcone(isRecharge, isEntree, isEchoue);
    final label = _buildLabel(isRecharge, isEntree);
    final montantFormate = _formatMontant(
      transaction.montant,
      isEntree,
      isEchoue,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // TODO: détail transaction
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // ── Icône ─────────────────────────────────────────────────
                icone,
                const SizedBox(width: 16),

                // ── Type + Date ───────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(transaction.dateCree),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isEchoue) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Échoué',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Montant ───────────────────────────────────────────────
                Text(
                  montantFormate,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: couleurMontant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcone(bool isRecharge, bool isEntree, bool isEchoue) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    if (isEchoue) {
      bgColor = AppColors.error.withAlpha(20);
      iconColor = AppColors.error;
      icon = Icons.close_rounded;
    } else if (isRecharge) {
      bgColor = AppColors.accent.withAlpha(20);
      iconColor = AppColors.accent;
      icon = Icons.add_rounded;
    } else if (isEntree) {
      bgColor = AppColors.success.withAlpha(20);
      iconColor = AppColors.success;
      icon = Icons.south_west_rounded;
    } else {
      bgColor = AppColors.info.withAlpha(20);
      iconColor = AppColors.info;
      icon = Icons.north_east_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  String _buildLabel(bool isRecharge, bool isEntree) {
    if (isRecharge) return 'Recharge';
    return isEntree ? 'Reçu via NFC' : 'Envoyé via NFC';
  }

  String _formatMontant(double montant, bool isEntree, bool isEchoue) {
    final formatted =
        NumberFormat('#,###', 'fr_FR').format(montant).replaceAll(',', ' ');
    if (isEchoue) return '$formatted FCFA';
    return '${isEntree ? '+' : '-'}$formatted FCFA';
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy · HH:mm', 'fr_FR').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
