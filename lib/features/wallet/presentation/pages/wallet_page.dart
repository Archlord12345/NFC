import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';
import '../widgets/solde_card.dart';
import '../widgets/transaction_tile.dart';
import '../../../../core/transfer/i_transfer_service.dart';
import '../../../nfc/data/services/nfc_transfer_service.dart';
import '../../data/services/bluetooth_transfer_service.dart';
import '../../data/services/quick_share_transfer_service.dart';
import 'solar_system_discovery_page.dart';

/// WA-1, WA-2, WA-3, WA-4 — Page principale du portefeuille.
///
/// Affiche :
/// - La [SoldeCard] avec le solde en temps réel
/// - Les actions rapides (Recharger, Historique, Envoyer NFC)
/// - Les 5 transactions les plus récentes
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    // Chargement différé pour laisser le widget tree se construire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().chargerWallet(
            context.read<String>(), // utilisateurId injecté dans main.dart
          );
    });
  }

  Future<void> _onRefresh() async {
    final userId = context.read<String>();
    await context.read<WalletProvider>().chargerWallet(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ───────────────────────────────────────────────────
            _buildSliverAppBar(context),

            // ── Contenu principal ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── AppBar ──────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'NFC Cash',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textSecondaryLight, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─────────────────────────── Body ────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        if (provider.status == WalletStatus.loading &&
            provider.wallet == null) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        if (provider.status == WalletStatus.error &&
            provider.wallet == null) {
          return _buildError(provider.errorMessage);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Carte de solde ─────────────────────────────────────────
            if (provider.wallet != null)
              SoldeCard(wallet: provider.wallet!),

            const SizedBox(height: 32),

            // ── Actions rapides ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActionsRapides(context),
            ),

            const SizedBox(height: 32),

            // ── Transactions récentes ──────────────────────────────────
            _buildTransactionsSection(context, provider),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  // ─────────────────────────── Actions rapides ─────────────────────────────

  Widget _buildActionsRapides(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          id: 'btn_recharger',
          icon: Icons.add_rounded,
          label: 'Recharger',
          color: AppColors.accent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RechargePage()),
          ),
        ),
        _ActionButton(
          id: 'btn_historique',
          icon: Icons.history_rounded,
          label: 'Historique',
          color: AppColors.info,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoriquePage()),
          ),
        ),
        _ActionButton(
          id: 'btn_nfc',
          icon: Icons.nfc_rounded,
          label: 'Envoyer',
          color: AppColors.warning,
          onTap: () => _showTransferMethodDialog(context),
        ),
        _ActionButton(
          id: 'btn_scan',
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scanner',
          color: AppColors.primarySoft,
          onTap: () {},
        ),
      ],
    );
  }

  void _showTransferMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Méthode d\'envoi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.nfc),
              title: const Text('NFC'),
              onTap: () => _handleTransfer(context, TransferMethod.nfc),
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Bluetooth'),
              onTap: () => _handleTransfer(context, TransferMethod.bluetooth),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Quick Share'),
              onTap: () => _handleTransfer(context, TransferMethod.quickShare),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTransfer(BuildContext context, TransferMethod method) {
    Navigator.pop(context); // Close dialog
    
    // Select the appropriate service implementation
    // This is a simplification; in a real app, you would use DI (e.g., GetIt)
    ITransferService? service;
    if (method == TransferMethod.nfc) service = NfcTransferService();
    if (method == TransferMethod.bluetooth) service = BluetoothTransferService();
    if (method == TransferMethod.quickShare) service = QuickShareTransferService();

    if (service != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SolarSystemDiscoveryPage(
            transferService: service!,
            amount: 100.0, // Example amount
          ),
        ),
      );
    }
  }

  // ─────────────────────────── Transactions récentes ───────────────────────

  Widget _buildTransactionsSection(
      BuildContext context, WalletProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transactions récentes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoriquePage()),
                ),
                child: const Text(
                  'Tout voir',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        if (provider.transactionsRecentes.isEmpty)
          _buildEmptyTransactions()
        else
          ...provider.transactionsRecentes.map(
            (tx) => TransactionTile(
              transaction: tx,
              currentWalletId: provider.wallet?.id ?? '',
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.textSecondaryLight.withAlpha(120)),
            const SizedBox(height: 12),
            const Text(
              'Aucune transaction pour le moment',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String? message) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Widget Action Button ─────────────────────────────

class _ActionButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withAlpha(40), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
