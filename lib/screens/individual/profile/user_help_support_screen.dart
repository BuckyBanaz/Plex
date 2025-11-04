import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:plex_user/constant/app_colors.dart';
import 'package:plex_user/screens/widgets/custom_button.dart';
import '../../../modules/controllers/settings/help_controller.dart';

class UserHelpSupportScreen extends GetView<HelpController> {
  const UserHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HelpController());

    return Scaffold(
      appBar: AppBar(
        title: Text('help_title'.tr),
        leading: IconButton(onPressed:()=> Get.back(), icon: Icon(CupertinoIcons.back)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'contact_us'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: AppColors.primarySwatch.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primarySwatch),
                ),
                child: Column(
                  children: [
                    _buildContactTile(
                      icon: IconlyBold.message,
                      title: 'contact_email'.tr,
                      subtitle: 'contact_email_desc'.tr,
                      onTap: controller.launchEmail,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16,color: AppColors.primarySwatch,),
                    _buildContactTile(
                      icon: IconlyBold.chat,
                      title: 'contact_chat'.tr,
                      subtitle: 'contact_chat_desc'.tr,
                      onTap: controller.launchChat,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'faq_title'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFaqTile('faq_q1'.tr, 'faq_a1'.tr),
              _buildFaqTile('faq_q2'.tr, 'faq_a2'.tr),
              _buildFaqTile('faq_q3'.tr, 'faq_a3'.tr),

              const SizedBox(height: 32),

                CustomButton(onTap: controller.submitNewTicket, widget: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconlyBold.ticket,color: AppColors.textColor),
                      SizedBox(width: 2,),
                      Text('submit_ticket'.tr,style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.textColor),)
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for contact options
  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Get.theme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }

  // Helper widget for FAQ items
  Widget _buildFaqTile(String questionKey, String answerKey) {
    return Card(
      elevation: 0,
      color: AppColors.primarySwatch.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.primarySwatch),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(questionKey.tr,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding:
        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(answerKey.tr),
        ],
      ),
    );
  }
}
