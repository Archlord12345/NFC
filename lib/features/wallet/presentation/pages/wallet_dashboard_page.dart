import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../presentation/providers/wallet_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../nfc/presentation/pages/nfc_scan_page.dart';

/// Page du Dashboard Wallet (écran principal après connexion).
///
/// Affiche le solde, les actions rapides (Recharge, Send via NFC)
/// et l'historique des transactions récentes.
class WalletDashboardPage extends StatelessWidget {
  const WalletDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Consumer2<AuthProvider, WalletProvider>(
          builder: (context, auth, walletProv, _) {
            if (walletProv.status == WalletStatus.loading && walletProv.wallet == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }

            final user = auth.utilisateur;
            final wallet = walletProv.wallet;

            return RefreshIndicator(
              onRefresh: () => walletProv.chargerWallet(user?.id ?? ''),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Header ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.email.split('@').first ?? 'User'}',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your NFC wallet is ready for transactions.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.accent,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Carte Solde ──
                    _BalanceCard(
                      theme: theme,
                      solde: wallet?.solde ?? 0.0,
                      devise: wallet?.devise ?? 'XAF',
                    ),
                    const SizedBox(height: 24),

                    // ── Actions rapides ──
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Recharge',
                            onTap: () {
                              _showRechargeDialog(context, walletProv);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.nfc_rounded,
                            label: 'Send',
                            isPrimary: true,
                            onTap: () {
                              Navigator.of(context).pushNamed('/nfc-scan', arguments: NfcMode.send);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.download_rounded,
                            label: 'Receive',
                            onTap: () {
                              Navigator.of(context).pushNamed('/nfc-scan', arguments: NfcMode.receive);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Historique ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            // On pourrait naviguer vers l'onglet History si on avait accès au contrôleur
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (walletProv.transactionsRecentes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No transactions yet.'),
                        ),
                      )
                    else
                      ...walletProv.transactionsRecentes.map((tx) => _TransactionTile(
                            transaction: tx,
                            currentWalletId: wallet?.id ?? '',
                          )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRechargeDialog(BuildContext context, WalletProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recharge'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Montant (ex: 5000)',
            prefixIcon: Icon(Icons.add_card),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final montant = double.tryParse(controller.text);
              if (montant != null && montant > 0) {
                final success = await provider.recharger(montant);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Recharge de ${provider.wallet?.devise} $montant effectuée !'
                          : 'Erreur lors de la recharge : ${provider.errorMessage}'),
                    ),
                  );
                }
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Widgets internes ───────────────────────────────

class _BalanceCard extends StatelessWidget {
  final ThemeData theme;
  final double solde;
  final String devise;

  const _BalanceCard({
    required this.theme,
    required this.solde,
    required this.devise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BALANCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Text(
                      'NFC ACTIVE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                solde.toStringAsFixed(2),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  devise,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_upward, color: AppColors.accent, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Balance up to date',
                style: TextStyle(color: AppColors.accent, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isPrimary
          ? AppColors.accent
          : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isPrimary ? Colors.white : AppColors.accent,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isPrimary
                      ? Colors.white
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final String currentWalletId;

  const _TransactionTile({
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
                  transaction.type == 'RECHARGE' ? 'Recharge' : 'NFC Transfer',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.dateCree.substring(0, 16).replaceAll('T', ' '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEntree ? '+' : '-'}${transaction.montant.toStringAsFixed(0)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isEntree ? AppColors.accent : AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
