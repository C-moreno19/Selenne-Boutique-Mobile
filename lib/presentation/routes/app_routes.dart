class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String newPassword = '/new-password';
  static const String passwordChanged = '/password-changed';

  // Main
  static const String home = '/home';
  static const String categories = '/categories';
  static const String search = '/search';

  // Shopping
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmed = '/order-confirmed';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String orderDetail = '/order-detail';
  static const String addresses = '/addresses';
  static const String shipments = '/shipments';

  // Settings
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String preferences = '/preferences';
  static const String terms = '/terms';
  static const String support = '/support';
  static const String favorites = '/favorites';

  // Products
  static const String productDetail = '/product-detail';

  // Categories
  static const String womenProducts = '/women-products';
  static const String dresses = '/dresses';
  static const String blouses = '/blouses';
  static const String pants = '/pants';
  static const String shoes = '/shoes';
  static const String accessories = '/accessories';
  static const String offers = '/offers';
}
