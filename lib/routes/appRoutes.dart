import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:plex_user/routes/middleware.dart';
import 'package:plex_user/screens/auth/companyRegisteration/company_registration_view.dart';
import 'package:plex_user/screens/auth/driver_signup_screen.dart';
import 'package:plex_user/screens/auth/signup_screen.dart';
import 'package:plex_user/screens/individual/Booking/booking_confirm_screen.dart';
import 'package:plex_user/screens/individual/Booking/booking_screen.dart';
import 'package:plex_user/screens/individual/Booking/confirm_details_screen.dart';
import 'package:plex_user/screens/individual/Booking/dropoff_details_screen.dart';
import 'package:plex_user/screens/individual/Booking/pickup_details_screen.dart';
import 'package:plex_user/screens/individual/dashboards/user_main_screen.dart';
import 'package:plex_user/screens/individual/home/user_home_screen.dart';
import 'package:plex_user/screens/individual/profile/user_profile_screen.dart';
import 'package:plex_user/screens/location/location_permission_screen.dart';
import 'package:plex_user/screens/notification/driver_notification_screen.dart';
import 'package:plex_user/screens/order/driver_delivery_order_screen.dart';
import 'package:plex_user/screens/payments/user_payment_screen.dart';

import '../screens/auth/choose_account_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/driver/dashboard/driver_dashboard_screen.dart';
import '../screens/driver/home/driver_home_screen.dart';
import '../screens/individual/Booking/location_details_screens.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const driverSignup = '/driverSignup';
  static const choose = '/choose';
  static const view = '/view';
  static const otp = '/otp';
  static const userDashBoard = '/userDashBoard';
  static const userHome = '/userHome';
  static const userProfile = '/userProfile';
  static const driverDashBoard = '/driverDashBoard';
  static const driverHome = '/driverHome';
  static const location = '/location';
  static const booking = '/booking';
  static const pickup = '/pickup';
  static const dropOff = '/dropOff';
  static const locationDetails = '/locationDetails';
  static const confirm = '/confirm';
  static const payment = '/payment';
  static const bookingConfirm = '/bookingConfirm';
  static const driverNotification = '/driverNotification';
  static const driverDeliveryOrder = '/driverDeliveryOrder';

  static get routes => [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen(),middlewares: [EnsureAuthMiddleware()]),
    GetPage(name: signup, page: () => SignupScreen()),
    GetPage(name: driverSignup, page: () => DriverSignupScreen()),
    GetPage(name: choose, page: () => ChooseAccountScreen()),
    GetPage(name: view, page: () => CompanyRegistrationScreen()),
    GetPage(name: otp, page: () => OtpScreen()),
    GetPage(name: userDashBoard, page: () => UserMainScreen()),
    GetPage(name: userHome, page: () => UserHomeScreen()),
    GetPage(name: driverDashBoard, page: () => DriverMainScreen()),
    GetPage(name: driverHome, page: () => DriverHomeScreen()),
    GetPage(name: location, page: () => LocationPermissionScreen()),
    GetPage(name: booking, page: () => BookingScreen()),
    GetPage(name: pickup, page: () => PickupDetailsScreen()),
    GetPage(name: dropOff, page: () => DropOffDetailsScreen()),
    GetPage(name: locationDetails, page: () => DetailLocationScreen()),
    GetPage(name: confirm, page: () => ConfirmDetailsScreen()),
    GetPage(name: payment, page: () => PaymentScreen()),
    GetPage(name: bookingConfirm, page: () => BookingConfirmScreen()),
    GetPage(name: driverNotification, page: () => DriverNotificationScreen()),
    GetPage(name: driverDeliveryOrder, page: () => DriverDeliveryOrderScreen()),
    GetPage(name: userProfile, page: () => UserProfileScreen()),
  ];
}
