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
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../nfc/presentation/pages/nfc_scan_page.dart';
import 'history_page.dart';
import 'historique_page.dart';
import 'recharge_page.dart';
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
    debugPrint('WalletPage: Chargement de la page Portefeuille');
    // Chargement différé pour laisser le widget tree se construire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().utilisateur?.id;
      if (userId != null) {
        context.read<WalletProvider>().chargerWallet(userId);
      }
    });
  }

  Future<void> _onRefresh() async {
    final userId = context.read<AuthProvider>().utilisateur?.id;
    if (userId != null) {
      await context.read<WalletProvider>().chargerWallet(userId);
    }
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
            MaterialPageRoute(builder: (_) => RechargePage()),
          ),
        ),
        _ActionButton(
          id: 'btn_historique',
          icon: Icons.history_rounded,
          label: 'Historique',
          color: AppColors.info,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HistoriquePage()),
          ),
        ),
        _ActionButton(
          id: 'btn_share',
          icon: Icons.share_rounded,
          label: 'Partager',
          color: AppColors.warning,
          onTap: () => _showTransferMethodDialog(context),
        ),
        _ActionButton(
          id: 'btn_receive',
          icon: Icons.download_rounded,
          label: 'Recevoir',
          color: AppColors.primarySoft,
          onTap: () => _showTransferMethodDialog(context, isReceiver: true),
        ),
      ],
    );
  }

  void _showTransferMethodDialog(BuildContext context, {bool isReceiver = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isReceiver ? 'Méthode de réception' : 'Méthode d\'envoi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.nfc),
              title: const Text('NFC'),
              onTap: () => _handleTransfer(context, TransferMethod.nfc, isReceiver),
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Bluetooth'),
              onTap: () => _handleTransfer(context, TransferMethod.bluetooth, isReceiver),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Quick Share'),
              onTap: () => _handleTransfer(context, TransferMethod.quickShare, isReceiver),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTransfer(BuildContext context, TransferMethod method, bool isReceiver) async {
    Navigator.pop(context); // Fermer le dialogue
    
    final wallet = context.read<WalletProvider>().wallet;
    if (wallet == null) return;

    if (method == TransferMethod.nfc) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NfcScanPage(mode: isReceiver ? NfcMode.receive : NfcMode.send),
        ),
      );
      return;
    }

    ITransferService? service;
    if (method == TransferMethod.bluetooth) service = BluetoothTransferService();
    if (method == TransferMethod.quickShare) service = QuickShareTransferService();

    if (service != null) {
      // Demander les permissions avant de naviguer
      bool granted = await service.requestPermissions();
      if (granted) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SolarSystemDiscoveryPage(
                transferService: service!,
                amount: 500.0,
                isReceiver: isReceiver,
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissions nécessaires non accordées.')),
          );
        }
      }
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
                  MaterialPageRoute(builder: (_) => HistoriquePage()),
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
