import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../constant/app_colors.dart';
import '../../models/driver_order_model.dart';

/// Reusable helper widget for the Info Section
class InfoColumnItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? titleSize;
  final double? subtitleSize;

  const InfoColumnItem(
      this.title,
      this.subtitle, {
        super.key,
        this.titleSize,
        this.subtitleSize,
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: titleSize ?? 13, // default 13 if not provided
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleSize ?? 15, // default 15 if not provided
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

String formattedDate(DateTime? dt) {
  if (dt == null) return '-';
  try {
    return DateFormat('dd MMM yyyy').format(dt);
  } catch (_) {
    return dt.toString();
  }
}

String formattedTime(DateTime? dt) {
  if (dt == null) return '-';
  try {
    return DateFormat('hh:mm a').format(dt);
  } catch (_) {
    return dt.toString();
  }
}
String formatDateTime(DateTime? dt) {
  if (dt == null) return '-';
  final d = dt.toLocal();
  final date = "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  final time = "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  return "$date • $time";
}

Widget buildStatusChip(OrderStatus status) {
  String text;
  Color bg = AppColors.primary;

  switch (status) {
    case OrderStatus.Delivered:
      text = "Completed";
      bg = Colors.green.shade600;
      break;
    case OrderStatus.Pending:
      text = "Pending";
      bg = Colors.orange.shade600;
      break;
    case OrderStatus.Cancelled:
      text = "Cancelled";
      bg = Colors.red.shade600;
      break;
    case OrderStatus.Created:
      text = "Created";
      bg = AppColors.primary;
      break;
    case OrderStatus.Assigned:
      text = "Assigned";
      bg = Colors.blue.shade600;
      break;
    case OrderStatus.Accepted:
      text = "Accepted";
      bg = Colors.teal.shade600;
      break;
    case OrderStatus.InTransit:
      text = "In Transit";
      bg = Colors.indigo.shade600;
      break;
    case OrderStatus.Declined:
      text = "Declined";
      bg = Colors.grey.shade600;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.textColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
