import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconly/iconly.dart' show IconlyLight;
import 'package:plex_user/modules/controllers/payment/user_payment_controller.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../individual/Booking/confirm_details_screen.dart';
import '../widgets/custom_button.dart';
import 'components/add_new_card_sheet.dart';
import 'components/cards_carousel.dart';
import 'components/other_payment_options.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    final UserPaymentController c = Get.put(UserPaymentController());
    return Scaffold(
      appBar: AppBar(
        title: Text("payment_title".tr),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(CupertinoIcons.back)),
      ),
      body: ListView(
        children: [
           CardsCarousel(controller: c, onTap: () {
             Get.bottomSheet(
               const AddNewCardSheet(),
               isScrollControlled: true,
               backgroundColor: Colors.transparent,
             );
           },),

          SizedBox(height: 16,),
          OtherPaymentOptions(),

          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: FareDetailsSection(),
          // ),
        ],
      ),
      bottomNavigationBar: CustomButton(onTap: (){
        c.proceedPayment();
        // Get.offAllNamed(AppRoutes.bookingConfirm);
      },widget: Center(
        child: Text(
          "pay_now".trParams({
            "amount": c.bookingController.amountPayable.toStringAsFixed(2)
          }),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),),
    );
  }
}
