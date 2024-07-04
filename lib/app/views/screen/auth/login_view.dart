import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goo_it/utils/common/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../router/app_routes.dart';
import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/text_style_ext.dart';
import '../../../../utils/common/loading_overlay.dart';
import '../../../controllers/auth_controller.dart';
import '../../widget/widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final ValueNotifier<bool> termsCheck = ValueNotifier(false);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final AuthController _authController = AuthController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      LoadingScreen.instance().show(context: context, text: "Sending Login...");
      try {
        final goRouter = GoRouter.of(context);

        final loginResult = await _authController.login(
          emailController.text,
          passwordController.text,
        );

        final role = loginResult['userData']['user']['role'];
        final userID = loginResult['userData']['user']['id'];
        print(userID);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userID', userID);
        await Future.delayed(const Duration(seconds: 1));

        // Display loading progress (optional)
        // for (var i = 0; i <= 100; i++) {
        //   LoadingScreen.instance().show(context: context, text: '$i %');
        //   await Future.delayed(const Duration(milliseconds: 10));
        // }

        // Hide loading screen
        LoadingScreen.instance()
            .show(context: context, text: "Login Successfully");
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();

        // Navigate based on user role
        if (role == 'admin') {
          goRouter.pushNamed(AppRoutes.admin.name);
        } else if (role == 'user') {
          goRouter.pushNamed(AppRoutes.user.name);
        } else {
          // Handle other roles as needed
          print('Unknown user role: $role');
        }
      } catch (e) {
        LoadingScreen.instance()
            .show(context: context, text: 'Login Failed: $e');
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();

        print(e);
      }
    }
  }

  // void _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       final goRouter = GoRouter.of(context);

  //       final user = await _authController.login(
  //         emailController.text,
  //         passwordController.text,
  //       );

  //       if (user != null) {
  //         LoadingScreen.instance()
  //             .show(context: context, text: "Sending Login...");
  //         await Future.delayed(const Duration(seconds: 1));

  //         // Display loading progress (optional)
  //         // for (var i = 0; i <= 100; i++) {
  //         //   LoadingScreen.instance().show(context: context, text: '$i %');
  //         //   await Future.delayed(const Duration(milliseconds: 10));
  //         // }

  //         // Hide loading screen
  //         LoadingScreen.instance()
  //             .show(context: context, text: "Login Successfully");
  //         await Future.delayed(const Duration(seconds: 1));
  //         LoadingScreen.instance().hide();

  //         ScaffoldMessenger.of(context)
  //             .showSnackBar(SnackBar(content: Text('Login Successful')));
  //         goRouter.pushNamed(AppRoutes.otpInput.name);

  //         // Navigate to the next screen
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Login Failed: User is null')));
  //       }
  //     } catch (e) {
  //       LoadingScreen.instance()
  //           .show(context: context, text: 'Login Failed: $e');
  //       await Future.delayed(const Duration(seconds: 1));
  //       LoadingScreen.instance().hide();
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Login Failed: $e')));
  //       print(e);
  //     }
  //   }
  // }

  // Future<void> _handleLogin() async {
  //   try {
  //     print("Starting login process");

  //     if (_formKey.currentState!.validate()) {
  //       print("Form validated");

  //       final goRouter = GoRouter.of(context);
  //       LoadingScreen.instance().show(context: context, text: "Signing In...");
  //       print("Showing loading screen");

  //       final response = await http.post(
  //         Uri.parse('http://10.0.2.2:5080/api/auth/login'),
  //         headers: {'Content-Type': 'application/json'}, // Add headers
  //         body: jsonEncode({
  //           'email': emailController.text,
  //           'password': passwordController.text,
  //         }),
  //       );

  //       print("Received response with status code: ${response.statusCode}");

  //       if (response.statusCode == 200) {
  //         final responseData = jsonDecode(response.body);
  //         print("Response data: $responseData");

  //         // Save token and user data in shared preferences
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('token', responseData['token']);
  //         await prefs.setInt('userId', responseData['user']['id']);
  //         await prefs.setString('username', responseData['user']['username']);
  //         await prefs.setString('email', responseData['user']['email']);
  //         await prefs.setString('createdAt', responseData['user']['createdAt']);

  //         print("Token and user data saved in shared preferences");

  //         LoadingScreen.instance()
  //             .show(context: context, text: "Signed In Successfully");
  //         await Future.delayed(const Duration(seconds: 1));
  //         LoadingScreen.instance().hide();
  //         goRouter.goNamed(AppRoutes.home.name);
  //       } else {
  //         LoadingScreen.instance().hide();
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Login failed. Please check your credentials.'),
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     LoadingScreen.instance().hide();
  //     print("Error during login: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 50),
              FadeInSlide(
                duration: .4,
                child: Text(
                  "Welcome Back! 👋",
                  style: context.hm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              FadeInSlide(
                duration: .5,
                child: Text(
                  "Gooit, For you",
                  style: context.tm,
                ),
              ),
              const SizedBox(height: 50),
              FadeInSlide(
                duration: .6,
                child: Text(
                  "Email",
                  style: context.tm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              FadeInSlide(
                duration: .6,
                child: EmailField(controller: emailController),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .7,
                child: Text(
                  "Password",
                  style: context.tm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              FadeInSlide(
                duration: .7,
                child: PasswordField(controller: passwordController),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .8,
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: termsCheck,
                      builder: (context, value, child) {
                        return CupertinoCheckbox(
                          inactiveColor: isDark ? Colors.white : Colors.black87,
                          value: value,
                          onChanged: (_) {
                            termsCheck.value = !termsCheck.value;
                          },
                        );
                      },
                    ),
                    Text("Remember Me", style: context.tm),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.forgotPassword.path),
                      child: const Text("Forgot Password?"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .8,
                child: RichTwoPartsText(
                  text1: "Don't have an account? ",
                  text2: "Sign Up",
                  onTap: () {
                    context.pushReplacementNamed(AppRoutes.signUp.name);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FadeInSlide(
        duration: 1,
        direction: FadeSlideDirection.btt,
        child: Container(
          padding:
              const EdgeInsets.only(bottom: 40, left: 20, right: 20, top: 30),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: .2, color: Colors.grey),
            ),
          ),
          child: FilledButton(
            onPressed: _login,
            style: FilledButton.styleFrom(
                fixedSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.seedColor),
            child: const Text(
              "Sign In",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
    );
  }
}
