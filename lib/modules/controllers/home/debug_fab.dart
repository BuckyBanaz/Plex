// // Put this in your page widget where controller is available.
// // Example: floatingActionButton: DebugFab(driverHomeController)
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'driver_home_controller.dart'; // import path as needed
//
// class DebugFab extends StatelessWidget {
//   final DriverHomeController controller = Get.put(DriverHomeController());
//
//   DebugFab({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FloatingActionButton(
//             heroTag: 'dump',
//             mini: true,
//             onPressed: () {
//               controller.showOrdersConsole();
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Console dumped')));
//             },
//             child: const Icon(Icons.list),
//             tooltip: 'Dump Orders (console)',
//           ),
//           const SizedBox(height: 8),
//           FloatingActionButton(
//             heroTag: 'ping',
//             onPressed: () {
//               controller.sendDebugPing();
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent client_ping')));
//             },
//             child: const Icon(Icons.send),
//             tooltip: 'Send client_ping to server',
//           ),
//         ],
//       ),
//     );
//   }
// }
