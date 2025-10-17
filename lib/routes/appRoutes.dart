

import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:plex_user/screens/auth/companyRegisteration/company_registration_view.dart';
import 'package:plex_user/screens/auth/driver_signup_screen.dart';
import 'package:plex_user/screens/auth/signup_screen.dart';
import 'package:plex_user/screens/dashboards/user_main_screen.dart';
import 'package:plex_user/screens/home/home_screen.dart';
import 'package:plex_user/screens/splash/splash_screen.dart';

import '../screens/auth/choose_account_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/partner_home_screen.dart';

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
  static const home = '/home';
  static const partnerHome = '/partnerHome';


  static get routes => [
    GetPage(name: splash, page: () =>  SplashScreen()),
    GetPage(name: login, page: () =>  LoginScreen()),
    GetPage(name: signup, page: () =>  SignupScreen()),
    GetPage(name: driverSignup, page: () =>  DriverSignupScreen()),
    GetPage(name: choose, page: () =>  ChooseAccountScreen()),
    GetPage(name: view, page: () =>  CompanyRegistrationScreen()),
    GetPage(name: otp, page: () =>  OtpScreen()),
    GetPage(name: userDashBoard, page: () =>  UserMainScreen()),
    GetPage(name: home, page: () =>  HomeScreen()),
    GetPage(name: partnerHome, page: () =>  PartnerHomeScreen()),

  ];
}
