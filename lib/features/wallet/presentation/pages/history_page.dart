import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../presentation/providers/wallet_provider.dart';

/// Page d'historique des transactions.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          if (provider.status == WalletStatus.loading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (provider.transactions.isEmpty) {
            return const Center(
              child: Text('No transactions found.'),
            );
          }

          // Grouper par date (simplifié : Today, Others)
          final today = DateTime.now().toIso8601String().substring(0, 10);
          final transactionsToday = provider.transactions
              .where((tx) => tx.dateCree.startsWith(today))
              .toList();
          final transactionsOlder = provider.transactions
              .where((tx) => !tx.dateCree.startsWith(today))
              .toList();

          return RefreshIndicator(
            onRefresh: () => provider.rafraichirHistorique(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (transactionsToday.isNotEmpty) ...[
                  _SectionHeader(title: 'Today', theme: theme, isDark: isDark),
                  ...transactionsToday.map((tx) => _HistoryTile(
                        transaction: tx,
                        currentWalletId: provider.wallet?.id ?? '',
                      )),
                  const SizedBox(height: 20),
                ],
                if (transactionsOlder.isNotEmpty) ...[
                  _SectionHeader(title: 'Older', theme: theme, isDark: isDark),
                  ...transactionsOlder.map((tx) => _HistoryTile(
                        transaction: tx,
                        currentWalletId: provider.wallet?.id ?? '',
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final TransactionEntity transaction;
  final String currentWalletId;

  const _HistoryTile({
    required this.transaction,
    required this.currentWalletId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEntree = transaction.estEntree(currentWalletId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: (isEntree ? AppColors.accent : AppColors.error).withValues(alpha: 0.1),
            child: Icon(
              transaction.type == 'RECHARGE' ? Icons.account_balance_wallet : Icons.nfc_rounded,
              color: isEntree ? AppColors.accent : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type == 'RECHARGE' ? 'Wallet Recharge' : 'NFC Transfer',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.dateCree.substring(11, 16), // HH:mm
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEntree ? '+' : '-'}${transaction.montant.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isEntree ? AppColors.accent : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: transaction.statut == 1 ? AppColors.accent : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transaction.statut == 1 ? 'Completed' : 'Failed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: transaction.statut == 1 ? AppColors.accent : AppColors.error,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
