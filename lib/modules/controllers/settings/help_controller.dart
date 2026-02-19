import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plex_user/screens/widgets/custom_snackbar.dart';

class HelpController extends GetxController {
  // --- Support Details ---
  // Inko aap apni actual details se replace karein
  final String supportPhoneNumber = '+911234567890';
  final String supportEmail = 'support@logisticsapp.com';
  final String emailSubject = 'Logistics App Support Request';

  // --- Logic Methods ---

  // Phone dialer launch karne ke liye
  void launchCall() async {
    final Uri url = Uri(scheme: 'tel', path: supportPhoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      CustomSnackbar.error(
        '${'error_cannot_launch'.tr} $supportPhoneNumber',
        title: 'error_title'.tr,
      );
    }
  }

  // Email app launch karne ke liye
  void launchEmail() async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=${Uri.encodeComponent(emailSubject)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      CustomSnackbar.error(
        '${'error_cannot_launch'.tr} $supportEmail',
        title: 'error_title'.tr,
      );
    }
  }

  // Live chat ke liye (filhaal placeholder)
  void launchChat() {
    // Yahan aap apne live chat (jaise Tawk.to, Crisp)
    // ka WebView ya SDK launch kar sakte hain
    CustomSnackbar.info(
      'chat_coming_soon'.tr,
      title: 'contact_chat'.tr,
    );
  }

  // Nayi support ticket screen par navigate karne ke liye
  void submitNewTicket() {
    // Example: Get.to(() => NewTicketScreen());
    CustomSnackbar.info(
      'Opening new ticket form...', // Isko bhi translate kar sakte hain
      title: 'submit_ticket'.tr,
    );
  }
}
