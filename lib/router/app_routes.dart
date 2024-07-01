class Route {
  String path;
  String name;
  Route({
    required this.path,
    required this.name,
  });
}

class AppRoutes {
  AppRoutes._();
  static Route onboard = Route(path: '/onboard', name: 'onboard');
  static Route getStarted = Route(path: '/getStarted', name: 'getStarted');

  static Route signUp = Route(path: '/signUp', name: 'signUp');
  static Route signIn = Route(path: '/signIn', name: 'signIn');
  static Route forgotPassword =
      Route(path: '/forgotPassword', name: 'forgotPassword');
  static Route otpInput = Route(path: '/otpInput', name: 'otpInput');
  static Route newPassword = Route(path: '/newPassword', name: 'newPassword');
  static Route passwordChanged =
      Route(path: '/passwordChanged', name: 'passwordChanged');
  static Route home = Route(path: '/', name: 'home');

  static Route user = Route(path: '/user', name: 'user');
  static Route userLine = Route(path: '/user/line', name: 'userLine');
  static Route userStation = Route(path: '/user/station', name: 'userStation');
  static Route userProfile = Route(path: '/user/profile', name: 'userProfile');
  static Route admin = Route(path: '/admin', name: 'admin');
}
