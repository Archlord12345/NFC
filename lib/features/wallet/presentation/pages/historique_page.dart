import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';
import '../widgets/transaction_tile.dart';

/// WA-2 — Historique complet des transactions.
///
/// Affiche toutes les transactions avec filtrage par type.
class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  String _filtre = 'Tout';
  final List<String> _filtres = ['Tout', 'Recharge', 'Transfert'];
  String _tri = 'dateDesc';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textPrimaryLight),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historique',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.textPrimaryLight),
            onSelected: (value) => setState(() => _tri = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'dateDesc',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 8),
                    Text('Plus récent'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'dateAsc',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 18),
                    SizedBox(width: 8),
                    Text('Plus ancien'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'amountDesc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 18),
                    SizedBox(width: 8),
                    Text('Montant décroissant'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'amountAsc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 18),
                    SizedBox(width: 8),
                    Text('Montant croissant'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          final wallet = provider.wallet;

          // Filtrage des transactions
          final txFiltrees = provider.transactions.where((tx) {
            if (_filtre == 'Recharge') return tx.type == 'RECHARGE';
            if (_filtre == 'Transfert') return tx.type == 'TRANSFERT_NFC';
            return true;
          }).toList();

          // Tri des transactions
          txFiltrees.sort((a, b) {
            switch (_tri) {
              case 'dateAsc':
                return a.dateCree.compareTo(b.dateCree);
              case 'amountDesc':
                return b.montant.compareTo(a.montant);
              case 'amountAsc':
                return a.montant.compareTo(b.montant);
              case 'dateDesc':
              default:
                return b.dateCree.compareTo(a.dateCree);
            }
          });

          return Column(
            children: [
              // ── Chips de filtre ─────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filtres
                        .map((f) => _buildFilterChip(f))
                        .toList(),
                  ),
                ),
              ),

              // ── Compteur ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${txFiltrees.length} transaction${txFiltrees.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Liste ────────────────────────────────────────────────────
              Expanded(
                child: txFiltrees.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: provider.rafraichirHistorique,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: txFiltrees.length,
                          itemBuilder: (context, index) => TransactionTile(
                            transaction: txFiltrees[index],
                            currentWalletId: wallet?.id ?? '',
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filtre == label;
    return GestureDetector(
      onTap: () => setState(() => _filtre = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.inputFillLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56,
              color: AppColors.textSecondaryLight.withAlpha(100)),
          const SizedBox(height: 16),
          const Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tes transactions apparaîtront ici',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
