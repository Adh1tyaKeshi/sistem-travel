import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────
// FILTER MODEL
// ─────────────────────────────────────────
class DestinationFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? category;
  final String? type; // 'accommodation', 'package', null = semua

  const DestinationFilter({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.category,
    this.type,
  });

  bool get hasActiveFilter =>
      minPrice != null ||
      maxPrice != null ||
      minRating != null ||
      category != null ||
      type != null;

  int get activeCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    if (category != null) count++;
    if (type != null) count++;
    return count;
  }

  DestinationFilter copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? category,
    String? type,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
    bool clearCategory = false,
    bool clearType = false,
  }) {
    return DestinationFilter(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      category: clearCategory ? null : (category ?? this.category),
      type: clearType ? null : (type ?? this.type),
    );
  }

  DestinationFilter clear() => const DestinationFilter();
}

// ─────────────────────────────────────────
// FILTER BAR WIDGET
// ─────────────────────────────────────────
class FilterBar extends StatelessWidget {
  final DestinationFilter filter;
  final ValueChanged<DestinationFilter> onFilterChanged;

  const FilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  String formatRupiah(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Filter icon button
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: filter.hasActiveFilter
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: filter.hasActiveFilter
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: filter.hasActiveFilter
                        ? Colors.white
                        : Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: filter.hasActiveFilter
                          ? Colors.white
                          : Colors.white54,
                      fontSize: 13,
                      fontWeight: filter.hasActiveFilter
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  if (filter.activeCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${filter.activeCount}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Active filter chips
          if (filter.type != null)
            _ActiveChip(
              label: filter.type == 'accommodation'
                  ? 'Akomodasi'
                  : 'Paket Wisata',
              onRemove: () => onFilterChanged(filter.copyWith(clearType: true)),
            ),
          if (filter.category != null)
            _ActiveChip(
              label: filter.category!,
              onRemove: () =>
                  onFilterChanged(filter.copyWith(clearCategory: true)),
            ),
          if (filter.minRating != null)
            _ActiveChip(
              label: '${filter.minRating!.toStringAsFixed(0)}★+',
              onRemove: () =>
                  onFilterChanged(filter.copyWith(clearMinRating: true)),
            ),
          if (filter.minPrice != null || filter.maxPrice != null)
            _ActiveChip(
              label: _priceLabel(filter),
              onRemove: () => onFilterChanged(
                filter.copyWith(clearMinPrice: true, clearMaxPrice: true),
              ),
            ),

          // Clear all
          if (filter.hasActiveFilter) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onFilterChanged(filter.clear()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: Text(
                    'Reset',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _priceLabel(DestinationFilter f) {
    if (f.minPrice != null && f.maxPrice != null) {
      return '${formatRupiah(f.minPrice!)} - ${formatRupiah(f.maxPrice!)}';
    } else if (f.minPrice != null) {
      return '> ${formatRupiah(f.minPrice!)}';
    } else {
      return '< ${formatRupiah(f.maxPrice!)}';
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        filter: filter,
        onApply: (newFilter) {
          onFilterChanged(newFilter);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: AppColors.primary, size: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// FILTER BOTTOM SHEET
// ─────────────────────────────────────────
class FilterBottomSheet extends StatefulWidget {
  final DestinationFilter filter;
  final ValueChanged<DestinationFilter> onApply;

  const FilterBottomSheet({
    super.key,
    required this.filter,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late double _minRating;
  late String? _category;
  late String? _type;
  String formatRupiah(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  static const double _maxPriceLimit = 10000000;

  final _categories = ['Beaches', 'Mountains', 'Cities', 'Forests', 'Islands'];

  @override
  void initState() {
    super.initState();
    _minPrice = widget.filter.minPrice ?? 0;
    _maxPrice = widget.filter.maxPrice ?? _maxPriceLimit;
    _minRating = widget.filter.minRating ?? 0;
    _category = widget.filter.category;
    _type = widget.filter.type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
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
                color: Colors.white.withOpacity(0.2),
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
                'Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _minPrice = 0;
                  _maxPrice = _maxPriceLimit;
                  _minRating = 0;
                  _category = null;
                  _type = null;
                }),
                child: const Text(
                  'Reset semua',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Tipe ──
          _SectionLabel('Tipe Destinasi'),
          const SizedBox(height: 10),
          Row(
            children: [
              _TypeChip(
                label: 'Semua',
                isSelected: _type == null,
                onTap: () => setState(() => _type = null),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Akomodasi',
                icon: Icons.villa_outlined,
                isSelected: _type == 'accommodation',
                onTap: () => setState(
                  () =>
                      _type = _type == 'accommodation' ? null : 'accommodation',
                ),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Paket Wisata',
                icon: Icons.luggage_outlined,
                isSelected: _type == 'package',
                onTap: () => setState(
                  () => _type = _type == 'package' ? null : 'package',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Kategori ──
          _SectionLabel('Kategori'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories
                .map(
                  (cat) => _TypeChip(
                    label: cat,
                    isSelected: _category == cat,
                    onTap: () => setState(
                      () => _category = _category == cat ? null : cat,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          // ── Harga ──
          _SectionLabel('Rentang Harga'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(_minPrice),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                _maxPrice >= _maxPriceLimit
                    ? '${formatRupiah(_maxPriceLimit)}+'
                    : formatRupiah(_maxPrice),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: _maxPriceLimit,
            divisions: 50,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white.withOpacity(0.15),
            onChanged: (v) => setState(() {
              _minPrice = v.start;
              _maxPrice = v.end;
            }),
          ),

          const SizedBox(height: 16),

          // ── Rating ──
          _SectionLabel('Rating Minimum'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [0, 1, 2, 3, 4, 5].map((r) {
              final selected = _minRating == r.toDouble();
              return GestureDetector(
                onTap: () => setState(
                  () => _minRating = r == _minRating ? 0 : r.toDouble(),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Center(
                    child: r == 0
                        ? Text(
                            'Semua',
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFFFFD700),
                                size: 13,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$r',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Apply button
          GestureDetector(
            onTap: () => widget.onApply(
              DestinationFilter(
                minPrice: _minPrice > 0 ? _minPrice : null,
                maxPrice: _maxPrice < _maxPriceLimit ? _maxPrice : null,
                minRating: _minRating > 0 ? _minRating : null,
                category: _category,
                type: _type,
              ),
            ),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: const Center(
                child: Text(
                  'Terapkan Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white54,
                size: 14,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
