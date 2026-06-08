import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/history/transaction_card.dart';
import '../../widgets/history/history_summary_card.dart';
import '../../widgets/history/filter_bottom_sheet.dart';
import 'transaction_detail_screen.dart';

/// Écran principal d'historique des transactions NFC
class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise les données au premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().init(widget.userId);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Déclenche la pagination infinie
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionProvider>().loadMore();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  void _openDetail(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text(
          'Voulez-vous supprimer toutes vos transactions ?\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<TransactionProvider>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Historique',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      actions: [
        Consumer<TransactionProvider>(
          builder: (_, provider, __) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: 'Filtres',
                onPressed: _openFilterSheet,
              ),
              if (provider.filterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${provider.filterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') _confirmClearHistory();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Effacer l\'historique',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un contact ou montant...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TransactionProvider>().applyFilter(
                          context
                              .read<TransactionProvider>()
                              .filter
                              .copyWith(searchQuery: ''),
                        );
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (query) {
          context.read<TransactionProvider>().applyFilter(
                context
                    .read<TransactionProvider>()
                    .filter
                    .copyWith(searchQuery: query),
              );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TransactionProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading && provider.transactions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        if (provider.hasError && provider.transactions.isEmpty) {
          return _buildErrorState(provider);
        }

        if (provider.transactions.isEmpty) {
          return _buildEmptyState(provider);
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          color: const Color(0xFF6C63FF),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: provider.transactions.length + 2, // +2 : résumé + loader
            itemBuilder: (_, index) {
              if (index == 0) {
                return HistorySummaryCard(summary: provider.summary);
              }

              final txIndex = index - 1;

              if (txIndex == provider.transactions.length) {
                return provider.hasMore
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              final transaction = provider.transactions[txIndex];
              return TransactionCard(
                transaction: transaction,
                currentUserId: widget.userId,
                onTap: () => _openDetail(transaction),
                onDelete: () => provider.deleteTransaction(transaction.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TransactionProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            provider.filterCount > 0
                ? Icons.search_off_rounded
                : Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            provider.filterCount > 0
                ? 'Aucun résultat trouvé'
                : 'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.filterCount > 0
                ? 'Essayez de modifier vos filtres'
                : 'Vos transferts NFC apparaîtront ici',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
          if (provider.filterCount > 0) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: provider.clearFilter,
              icon: const Icon(Icons.clear_all),
              label: const Text('Réinitialiser les filtres'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(TransactionProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? '',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: provider.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }
}
