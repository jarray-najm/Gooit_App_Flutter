import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

import '../app/views/screen/admin/admin_view.dart';
import '../app/views/screen/auth/otp/forgot_password_view.dart';
import '../app/views/screen/auth/get_started_view.dart';
import '../app/views/screen/auth/login_view.dart';
import '../app/views/screen/auth/otp/new_password_view.dart';
import '../app/views/screen/auth/otp/otp_input_view.dart';
import '../app/views/screen/auth/otp/password_changed_view.dart';
import '../app/views/screen/auth/signup_view.dart';
import '../app/views/screen/onboarding/onboarding_view.dart';
import '../app/views/screen/user/home_user.dart';
import 'app_routes.dart';

final router = GoRouter(
  initialLocation: AppRoutes.onboard.path,
  // redirect: (context, state) async{

  // },
  routes: [
    GoRoute(
      path: AppRoutes.onboard.path,
      name: AppRoutes.onboard.name,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: AppRoutes.getStarted.path,
      name: AppRoutes.getStarted.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: GetStartedView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUp.path,
      name: AppRoutes.signUp.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: SignUpView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signIn.path,
      name: AppRoutes.signIn.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: LoginView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword.path,
      name: AppRoutes.forgotPassword.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: ForgotPasswordView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.otpInput.path,
      name: AppRoutes.otpInput.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: OTPInputView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.newPassword.path,
      name: AppRoutes.newPassword.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: NewPasswordView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.passwordChanged.path,
      name: AppRoutes.passwordChanged.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: PasswordChangedView(),
      ),
    ),
    // GoRoute(
    //   path: AppRoutes.home.path,
    //   name: AppRoutes.home.name,
    //   pageBuilder: (context, state) => const CupertinoPage(
    //     child: HomeView(),
    //   ),
    // ),
    GoRoute(
      path: AppRoutes.user.path,
      name: AppRoutes.user.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: HomeUser(),
      ),
    ),
    GoRoute(
      path: AppRoutes.admin.path,
      name: AppRoutes.admin.name,
      pageBuilder: (context, state) => const CupertinoPage(
        child: AdminView(),
      ),
    ),
  ],
);
