import 'package:flutter/material.dart';

class FareRowItem extends StatelessWidget {
  final String title;
  final String amount;
  final bool isBold;

  const FareRowItem(
      this.title,
      this.amount, {
        this.isBold = false,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: isBold ? Colors.black : Colors.grey[700],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}