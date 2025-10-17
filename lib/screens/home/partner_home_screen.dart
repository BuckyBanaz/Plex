import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../constant/app_colors.dart';

class PartnerHomeScreen extends StatefulWidget {
  const PartnerHomeScreen({Key? key}) : super(key: key);

  @override
  State<PartnerHomeScreen> createState() => _PartnerHomeScreenState();
}

class _PartnerHomeScreenState extends State<PartnerHomeScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ---- Top header area (dark blue) ----
            Container(
              width: double.infinity,
              height: h * 0.28,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // --- Notification Bell ---
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      IconlyLight.notification,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // --- Text Column (Partner + Earnings) ---
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    right: w * 0.34,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        Text(
                          'Partner',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Vipin Jain',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          'My Earnings',
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '\$ 130.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Rider Image ---
                  Positioned(
                    right: 0,
                    bottom: -10, // lifts image slightly above bottom curve
                    child: Image.asset(
                      'assets/images/driver.png',
                      height: h * 0.22,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // --- STATUS CONTAINER (Separate from Stack) ---
            Transform.translate(
              offset: const Offset(0, -18), // pulls it slightly up for overlap look
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // --- Status Text ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status - ${isOnline ? "Online" : "Offline"}',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Open to any delivery',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Custom Switch ---
                    GestureDetector(
                      onTap: () => setState(() => isOnline = !isOnline),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 50,
                        height: 26,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? AppColors.primary
                              : AppColors.primarySwatch.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Align(
                          alignment: isOnline
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Body area (white card-like background) ----
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The pale card for "2 Delivery order found!"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // left text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '2 Delivery order found!',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'View details!',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // box icon on right
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // placeholder
                    const Expanded(
                      child: Center(
                        child: Text(
                          '— Empty area —\nAdd your list / map / deliveries here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
