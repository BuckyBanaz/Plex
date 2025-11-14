import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:plex_user/constant/app_colors.dart';

// --- Models ---
class Ride {
  final String pickup;
  final String dropoff;
  final DateTime dateTime;
  final double amount;
  final String paymentMethod; // e.g. 'UPI'
  final String status; // 'completed', 'cancelled', 'pending'

  Ride({
    required this.pickup,
    required this.dropoff,
    required this.dateTime,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });
}

// --- Controller (GetX) ---
class MyRidesController extends GetxController {
  final allRides = <Ride>[].obs;
  final filtered = <String, List<Ride>>{}.obs; // grouped map
  final activeTab = 'All'.obs; // All, Completed, Cancelled

  @override
  void onInit() {
    super.onInit();
    _populateDummy();
    _applyFilter();
  }

  void _populateDummy() {
    final now = DateTime.now();
    allRides.assignAll([
      Ride(
        pickup: 'Gbagi market road, sector, Jaipur',
        dropoff: 'Tulip Pharmacy, sector 15, Jaipur',
        dateTime: DateTime(now.year, now.month, now.day, 12, 59),
        amount: 230,
        paymentMethod: 'UPI',
        status: 'completed',
      ),
      Ride(
        pickup: 'Gbagi market road, sector, Jaipur',
        dropoff: 'Tulip Pharmacy, sector 15, Jaipur',
        dateTime: DateTime(now.year, now.month, now.day, 14, 0),
        amount: 230,
        paymentMethod: 'Cash',
        status: 'completed',
      ),
      // Yesterday
      Ride(
        pickup: 'Gbagi market road, sector, Jaipur',
        dropoff: 'Tulip Pharmacy, sector 15, Jaipur',
        dateTime: now.subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
        amount: 230,
        paymentMethod: 'UPI',
        status: 'completed',
      ),
      Ride(
        pickup: 'Gbagi market road, sector, Jaipur',
        dropoff: 'Tulip Pharmacy, sector 15, Jaipur',
        dateTime: now.subtract(const Duration(days: 1)).add(const Duration(hours: 3)),
        amount: 230,
        paymentMethod: 'UPI',
        status: 'cancelled',
      ),
      // older date
      Ride(
        pickup: 'New Market Road, Jaipur',
        dropoff: 'Central Mall, Jaipur',
        dateTime: now.subtract(const Duration(days: 4)).add(const Duration(hours: 2)),
        amount: 320,
        paymentMethod: 'Card',
        status: 'completed',
      ),
    ]);
  }

  void setTab(String tab) {
    activeTab.value = tab;
    _applyFilter();
  }

  void _applyFilter() {
    // filter by tab
    List<Ride> list;
    if (activeTab.value == 'All') {
      list = List.from(allRides);
    } else if (activeTab.value == 'Completed') {
      list = allRides.where((r) => r.status == 'completed').toList();
    } else {
      list = allRides.where((r) => r.status == 'cancelled').toList();
    }

    // group by day label
    final Map<String, List<Ride>> groups = {};

    for (var r in list) {
      final label = _dayLabel(r.dateTime);
      groups.putIfAbsent(label, () => []).add(r);
    }

    // sort groups so Today, Yesterday first, then by date descending
    final sortedKeys = groups.keys.toList()..sort((a, b) {
      final aDate = _parseGroupKey(a);
      final bDate = _parseGroupKey(b);
      return bDate.compareTo(aDate);
    });

    final sortedMap = <String, List<Ride>>{};
    for (var k in sortedKeys) {
      // sort rides in descending time inside group
      groups[k]!.sort((x, y) => y.dateTime.compareTo(x.dateTime));
      sortedMap[k] = groups[k]!;
    }

    filtered.assignAll(sortedMap);
  }

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    final dtDate = DateTime(dt.year, dt.month, dt.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dtDate == today) return 'Today';
    if (dtDate == yesterday) return 'Yesterday';

    return DateFormat('dd MMM, yyyy').format(dtDate);
  }

  DateTime _parseGroupKey(String key) {
    if (key == 'Today') return DateTime.now();
    if (key == 'Yesterday') return DateTime.now().subtract(const Duration(days: 1));
    try {
      return DateFormat('dd MMM, yyyy').parse(key);
    } catch (_) {
      return DateTime(1970);
    }
  }
}

// --- UI Screen ---
class DriverRideScreen extends StatelessWidget {
  const DriverRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyRidesController());

    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            const SizedBox(height: 8),

            // Tab bar (if it itself uses observables, it should handle its own Obx internally)
            _TabBarWidget(controller: controller),

            const SizedBox(height: 8),

            // Expanded provides bounded height to the inner ListView
            Expanded(
              child: Obx(() {
                // Access the RxMap inside Obx so GetX can track changes
                final groupedEntries = controller.filtered.entries.toList();

                if (groupedEntries.isEmpty) {
                  return const Center(child: Text('No rides found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = groupedEntries[index];
                    final key = entry.key;
                    final rides = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            key,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        // build ride cards
                        ...rides.map((r) => _RideCard(ride: r)).toList(),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Top bar with rounded center buttons (search + filter) ---
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'My Rides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundIconButton(icon: CupertinoIcons.search, onTap: () {}),
             SizedBox(width: 10,),
              RoundIconButton(icon: IconlyLight.filter, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE6ECF5),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: AppColors.secondary, // navy blue like image
          ),
        ),
      ),
    );
  }
}


// --- Tab bar ---
// Tab bar widget that updates reactively with GetX
class _TabBarWidget extends StatelessWidget {
  final MyRidesController controller;
  const _TabBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.activeTab.value;
      return Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'All',
              selected: active == 'All',
              onTap: () => controller.setTab('All'),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Completed',
              selected: active == 'Completed',
              onTap: () => controller.setTab('Completed'),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Cancelled',
              selected: active == 'Cancelled',
              onTap: () => controller.setTab('Cancelled'),
            ),
          ),
        ],
      );
    });
  }
}

// Improved tab button: ripple, animation, and underline indicator
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: selected ? Colors.black : Colors.grey.shade700,
                ),
              ),
            ),

            // small space and underline indicator
            AnimatedContainer(
              duration:  Duration(milliseconds: 200),
              height: 3,
              width: double.infinity,
              // animate the visibility using width and opacity
              // wrap in Opacity if you want fade effect
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Ride Card --
class _RideCard extends StatelessWidget {
  final Ride ride;
  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isCompleted = ride.status == "completed";
    final timeLabel = DateFormat('h:mm a').format(ride.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Icons (auto aligned to text height)
                Column(
                  children: [
                    Icon(Icons.my_location, color: AppColors.primary, size: 24),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.primary.withOpacity(0.4),
                      ),
                    ),
                    Icon(IconlyLight.location, color: AppColors.primary, size: 26),
                  ],
                ),

                const SizedBox(width: 14),

                // Middle Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.pickup,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        ride.dropoff,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Amount + Payment method
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.money, size: 20),
                  const SizedBox(width: 6),

                  // Amount (red if cancelled)
                  Text(
                    "₹${ride.amount.toInt()}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? Colors.black : Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              // Payment type only for completed
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ride.paymentMethod,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
