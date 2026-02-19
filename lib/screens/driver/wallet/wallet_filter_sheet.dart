import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constant/app_colors.dart';

class WalletFilterSheet extends StatefulWidget {
  final String? selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> selectedStatuses;
  final int totalResults;
  final Function(String?, DateTime?, DateTime?, Set<String>) onApply;

  const WalletFilterSheet({
    super.key,
    this.selectedPeriod,
    this.startDate,
    this.endDate,
    required this.selectedStatuses,
    required this.totalResults,
    required this.onApply,
  });

  @override
  State<WalletFilterSheet> createState() => _WalletFilterSheetState();
}

class _WalletFilterSheetState extends State<WalletFilterSheet> {
  late String? _selectedPeriod;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late Set<String> _selectedStatuses;

  final List<String> _periods = [
    'Today',
    'This week',
    'This month',
    'Previous month',
    'This year',
  ];

  final List<String> _statuses = [
    'Confirmed',
    'Pending',
    'Canceled',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod;
    _startDate = widget.startDate ?? DateTime(2024, 12, 11);
    _endDate = widget.endDate ?? DateTime(2025, 9, 20);
    _selectedStatuses = Set.from(widget.selectedStatuses);
  }

  void _clearAll() {
    setState(() {
      _selectedPeriod = null;
      _startDate = null;
      _endDate = null;
      _selectedStatuses.clear();
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart 
          ? (_startDate ?? DateTime.now()) 
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _selectedPeriod = null; // Clear period when custom date selected
      });
    }
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = _selectedPeriod == period ? null : period;
      
      // Auto-set date range based on period
      final now = DateTime.now();
      switch (period) {
        case 'Today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'This week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'This month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Previous month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case 'This year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
      }
    });
  }

  void _toggleStatus(String status) {
    setState(() {
      final statusLower = status.toLowerCase();
      if (_selectedStatuses.contains(statusLower)) {
        _selectedStatuses.remove(statusLower);
      } else {
        _selectedStatuses.add(statusLower);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Section
                const Text(
                  'Period',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _periods.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return _FilterChip(
                      label: period,
                      isSelected: isSelected,
                      onTap: () => _selectPeriod(period),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Date Range Section
                const Text(
                  'Select period',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        date: _startDate,
                        onTap: () => _selectDate(true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '-',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DateButton(
                        date: _endDate,
                        onTap: () => _selectDate(false),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Status Section
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _statuses.map((status) {
                    final isSelected = _selectedStatuses.contains(status.toLowerCase());
                    return _FilterChip(
                      label: status,
                      isSelected: isSelected,
                      onTap: () => _toggleStatus(status),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          // Apply Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _selectedPeriod,
                      _startDate,
                      _endDate,
                      _selectedStatuses,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Show results (${widget.totalResults})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              date != null 
                  ? DateFormat('dd MMM yyyy').format(date!)
                  : 'Select date',
              style: TextStyle(
                color: date != null ? AppColors.secondary : Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
