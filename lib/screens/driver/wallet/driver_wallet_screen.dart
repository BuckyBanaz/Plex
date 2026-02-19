import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../constant/app_colors.dart';
import 'wallet_filter_sheet.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  // Filter state
  String? selectedPeriod;
  DateTime? startDate;
  DateTime? endDate;
  Set<String> selectedStatuses = {};
  
  // Mock data - replace with actual API data
  final double totalEarnings = 130.00;
  final List<WalletTransaction> transactions = [
    WalletTransaction(
      id: '564925374920',
      type: TransactionType.cashIn,
      title: 'Cash-in',
      subtitle: 'From ABC Bank ATM',
      amount: 100.00,
      status: TransactionStatus.confirmed,
      dateTime: DateTime(2025, 10, 27, 10, 34),
    ),
    WalletTransaction(
      id: '564925374920',
      type: TransactionType.upiTransfer,
      title: 'Transfer to UPI',
      subtitle: 'From ABC Bank ATM',
      amount: 100.00,
      status: TransactionStatus.confirmed,
      dateTime: DateTime(2025, 10, 27, 10, 34),
    ),
    WalletTransaction(
      id: '564925374920',
      type: TransactionType.cardTransfer,
      title: 'Transfer to Card',
      subtitle: 'From ABC Bank ATM',
      amount: 100.00,
      status: TransactionStatus.confirmed,
      dateTime: DateTime(2025, 10, 27, 10, 34),
    ),
    WalletTransaction(
      id: '564925374920',
      type: TransactionType.cardTransfer,
      title: 'Transfer to Card',
      subtitle: 'Not enough funds',
      amount: 100.00,
      status: TransactionStatus.canceled,
      dateTime: DateTime(2025, 10, 27, 10, 34),
    ),
    WalletTransaction(
      id: '564925374920',
      type: TransactionType.cardTransfer,
      title: 'Transfer to Card',
      subtitle: 'Not enough funds',
      amount: 100.00,
      status: TransactionStatus.pending,
      dateTime: DateTime(2025, 10, 27, 10, 34),
    ),
    WalletTransaction(
      id: '564925374920',
      type: TransactionType.cardTransfer,
      title: 'Transfer to Card',
      subtitle: 'Not enough funds',
      amount: 100.00,
      status: TransactionStatus.pending,
      dateTime: DateTime(2025, 10, 27, 10, 34),
    ),
  ];

  List<WalletTransaction> get filteredTransactions {
    return transactions.where((t) {
      // Filter by status
      if (selectedStatuses.isNotEmpty) {
        final statusStr = t.status.name.toLowerCase();
        if (!selectedStatuses.contains(statusStr)) return false;
      }
      
      // Filter by date range
      if (startDate != null && t.dateTime.isBefore(startDate!)) return false;
      if (endDate != null && t.dateTime.isAfter(endDate!)) return false;
      
      return true;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WalletFilterSheet(
        selectedPeriod: selectedPeriod,
        startDate: startDate,
        endDate: endDate,
        selectedStatuses: selectedStatuses,
        totalResults: filteredTransactions.length,
        onApply: (period, start, end, statuses) {
          setState(() {
            selectedPeriod = period;
            startDate = start;
            endDate = end;
            selectedStatuses = statuses;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            // Transaction List
            Expanded(
              child: filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.grey.shade200,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        return _TransactionCard(
                          transaction: filteredTransactions[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'myEarnings'.tr,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _ActionButton(
                    icon: CupertinoIcons.search,
                    onTap: () {
                      // TODO: Implement search
                    },
                  ),
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: Icons.tune,
                    onTap: _openFilterSheet,
                    hasFilter: selectedPeriod != null || selectedStatuses.isNotEmpty,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Total Amount
          Text(
            '\$ ${totalEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasFilter;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.hasFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            if (hasFilter)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconBgColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: _buildIcon(),
            ),
          ),
          const SizedBox(width: 14),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '\$ ${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction ID',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          transaction.id,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(transaction.dateTime),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(transaction.dateTime),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: transaction.status),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconBgColor() {
    switch (transaction.type) {
      case TransactionType.cashIn:
        return const Color(0xFFFFF3E0);
      case TransactionType.upiTransfer:
        return const Color(0xFFE3F2FD);
      case TransactionType.cardTransfer:
        return const Color(0xFFFFF3E0);
    }
  }

  Widget _buildIcon() {
    switch (transaction.type) {
      case TransactionType.cashIn:
        return const Icon(
          Icons.credit_card,
          color: AppColors.primary,
          size: 24,
        );
      case TransactionType.upiTransfer:
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'UPI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case TransactionType.cardTransfer:
        return const Icon(
          Icons.credit_card,
          color: AppColors.primary,
          size: 24,
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case TransactionStatus.confirmed:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'confirmed';
        break;
      case TransactionStatus.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        label = 'pending';
        break;
      case TransactionStatus.canceled:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'canceled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Data models
enum TransactionType { cashIn, upiTransfer, cardTransfer }
enum TransactionStatus { confirmed, pending, canceled }

class WalletTransaction {
  final String id;
  final TransactionType type;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionStatus status;
  final DateTime dateTime;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.dateTime,
  });
}
