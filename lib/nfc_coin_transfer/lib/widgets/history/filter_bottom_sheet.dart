import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../models/transaction_filter.dart';
import '../../providers/transaction_provider.dart';

/// Feuille de filtres pour l'historique des transactions
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TransactionFilter _localFilter;

  static const Color _primary = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _localFilter = context.read<TransactionProvider>().filter;
  }

  Future<void> _applyAndClose() async {
    Navigator.pop(context);
    await context.read<TransactionProvider>().applyFilter(_localFilter);
  }

  void _reset() {
    setState(() => _localFilter = const TransactionFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              TextButton(
                onPressed: _reset,
                child: const Text('Réinitialiser',
                    style: TextStyle(color: _primary)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Type de transaction
          _SectionLabel('Type de transaction'),
          const SizedBox(height: 8),
          _TypeSelector(
            selected: _localFilter.type,
            onSelected: (type) {
              setState(() {
                _localFilter = _localFilter.copyWith(
                  type: type,
                  clearType: type == null,
                );
              });
            },
          ),
          const SizedBox(height: 20),

          // Statut
          _SectionLabel('Statut'),
          const SizedBox(height: 8),
          _StatusSelector(
            selected: _localFilter.status,
            onSelected: (status) {
              setState(() {
                _localFilter = _localFilter.copyWith(
                  status: status,
                  clearStatus: status == null,
                );
              });
            },
          ),
          const SizedBox(height: 20),

          // Période
          _SectionLabel('Période'),
          const SizedBox(height: 8),
          _DateRangeSelector(
            startDate: _localFilter.startDate,
            endDate: _localFilter.endDate,
            onChanged: (start, end) {
              setState(() {
                _localFilter = _localFilter.copyWith(
                  startDate: start,
                  endDate: end,
                );
              });
            },
          ),
          const SizedBox(height: 28),

          // Bouton appliquer
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _applyAndClose,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _localFilter.isEmpty
                    ? 'Voir tout'
                    : 'Appliquer (${_localFilter.activeCount})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sous-widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9999BB),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final TransactionType? selected;
  final ValueChanged<TransactionType?> onSelected;

  const _TypeSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final types = [
      (null, 'Tous'),
      (TransactionType.transfer, 'Envoi'),
      (TransactionType.receive, 'Réception'),
      (TransactionType.topUp, 'Recharge'),
    ];

    return Wrap(
      spacing: 8,
      children: types.map((entry) {
        final isSelected = selected == entry.$1;
        return ChoiceChip(
          label: Text(entry.$2),
          selected: isSelected,
          onSelected: (_) => onSelected(entry.$1),
          selectedColor: const Color(0xFF6C63FF).withOpacity(0.15),
          labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : const Color(0xFF555577),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.grey.shade300,
          ),
          backgroundColor: Colors.white,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final TransactionStatus? selected;
  final ValueChanged<TransactionStatus?> onSelected;

  const _StatusSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      (null, 'Tous'),
      (TransactionStatus.completed, 'Complétée'),
      (TransactionStatus.pending, 'En attente'),
      (TransactionStatus.failed, 'Échouée'),
    ];

    return Wrap(
      spacing: 8,
      children: statuses.map((entry) {
        final isSelected = selected == entry.$1;
        return ChoiceChip(
          label: Text(entry.$2),
          selected: isSelected,
          onSelected: (_) => onSelected(entry.$1),
          selectedColor: const Color(0xFF6C63FF).withOpacity(0.15),
          labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : const Color(0xFF555577),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.grey.shade300,
          ),
          backgroundColor: Colors.white,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end) onChanged;

  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6C63FF),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      onChanged(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = startDate != null || endDate != null;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pick(context),
            icon: Icon(
              Icons.date_range,
              size: 16,
              color: hasRange
                  ? const Color(0xFF6C63FF)
                  : Colors.grey.shade500,
            ),
            label: Text(
              hasRange
                  ? '${_fmt(startDate)}  →  ${_fmt(endDate)}'
                  : 'Sélectionner une période',
              style: TextStyle(
                color: hasRange
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: hasRange
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (hasRange) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => onChanged(null, null),
            icon: const Icon(Icons.clear, size: 18),
            color: Colors.grey.shade500,
          ),
        ],
      ],
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}
