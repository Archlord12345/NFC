import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Section du jour ──
          _SectionHeader(title: 'Today', theme: theme, isDark: isDark),
          _HistoryTile(
            icon: Icons.nfc_rounded,
            title: 'NFC Transfer to Marc',
            date: '10:32 AM',
            amount: '-€25.00',
            status: 'Completed',
            statusColor: AppColors.accent,
            isNegative: true,
          ),
          _HistoryTile(
            icon: Icons.account_balance_wallet,
            title: 'Wallet Recharge',
            date: '08:15 AM',
            amount: '+€100.00',
            status: 'Completed',
            statusColor: AppColors.accent,
            isNegative: false,
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: 'Yesterday', theme: theme, isDark: isDark),
          _HistoryTile(
            icon: Icons.nfc_rounded,
            title: 'NFC Transfer from Julie',
            date: '04:20 PM',
            amount: '+€50.00',
            status: 'Completed',
            statusColor: AppColors.accent,
            isNegative: false,
          ),
          _HistoryTile(
            icon: Icons.nfc_rounded,
            title: 'NFC Transfer to Paul',
            date: '02:10 PM',
            amount: '-€15.00',
            status: 'Failed',
            statusColor: AppColors.error,
            isNegative: true,
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: 'This Week', theme: theme, isDark: isDark),
          _HistoryTile(
            icon: Icons.account_balance_wallet,
            title: 'Wallet Recharge',
            date: 'Mon, 09:00 AM',
            amount: '+€200.00',
            status: 'Completed',
            statusColor: AppColors.accent,
            isNegative: false,
          ),
        ],
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
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;
  final bool isNegative;

  const _HistoryTile({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            backgroundColor: AppColors.accent.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  date,
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
                amount,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isNegative ? AppColors.error : AppColors.accent,
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
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
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
