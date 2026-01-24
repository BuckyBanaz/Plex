import 'package:get/get.dart';

class DriverNotificationController extends GetxController {


  final RxList<Map<String, String>> notifications = <Map<String, String>>[
    {
      'id': 'PLEX#: 004-12092283',
      'message': 'New work order',
      'time': '6 mins ago',
    },
    {
      'id': 'PLEX#: 004-12092282',
      'message': 'New work order',
      'time': '10 mins ago',
    },
    {
      'id': 'SYSTEM',
      'message': 'Your payment has been processed.',
      'time': '1 hour ago',
    },
    {
      'id': 'PLEX#: 004-12092281',
      'message': 'Order #1250 has been cancelled.',
      'time': '2 hours ago',
    },
    {
      'id': 'PLEX#: 004-12092280',
      'message': 'New work order',
      'time': '3 hours ago',
    },
    {
      'id': 'PLEX#: 004-12092279',
      'message': 'New work order',
      'time': '3 hours ago',
    },
  ].obs;

}