class ApiEndpoint {
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For iOS simulator, use localhost
  // For web/desktop, use localhost
  static const baseUrl = "http://10.0.2.2:3000";
  static const login = "/login";
  static const forgotPassword = "/forgot-password";
  static const resetPassword = "/reset-password";
  static const individualSignup = "/individual";
  static const driverSignup = "/driver";
  static const corporateSignup = "/corporate";
  static const guestSignup = "/guest";
  static const driverKyc = "/driver/kyc";
  static const verifyOtp = "/verify-otp";
  static const resendOtp = '/resend-otp';
  static const resendSms = "/verify-otp";
  static const refreshToken = "/refresh-token";
  static const location = "/location";
  static const userAddress = "/address";
  static const fcmToken = "/update-fcm";
  static const updateStatus = "/update-online-status";
  
  // Driver location
  static const driverLocation = "/driver/location";

  //
  static const shipment = "/shipments";
  static const estimateShipment = "$shipment/estimate";
  static const createShipment = "$shipment/create";
  static const getShipments = '/shipments';
  static const acceptShipment = '/shipments/:id/accept';
  static const rejectShipment = '/shipments/:id/reject';
  static const pickupShipment = '/shipments/:id/pickup';
  static const startTransit = '/shipments/:id/start-transit';
  static const deliverShipment = '/shipments/:id/deliver';
  static const driverTracking = '/shipments/:id/location';
  
  // OTP verification for shipments
  static const verifyPickupOtp = '/shipments/:id/verify-pickup-otp';
  static const verifyDropoffOtp = '/shipments/:id/verify-dropoff-otp';
  static const resendShipmentOtp = '/shipments/:id/resend-otp';
  
  // Driver active orders
  static const driverActiveOrders = '/shipments/driver/active';
  
  // User Profile
  static const userProfile = '/user/profile';
  
  // Notifications
  static const notifications = '/notifications';
  static const notificationUnreadCount = '/notifications/unread-count';
  static const notificationMarkAllRead = '/notifications/mark-all-read';
  static const notificationClearAll = '/notifications/clear-all';
}
