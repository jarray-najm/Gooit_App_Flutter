import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../../utils/common/loading_overlay.dart';
import '../../../../utils/common/text_style_ext.dart';
import '../../../controllers/auth_controller.dart';
import '../../widget/widgets.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final ValueNotifier<bool> termsCheck = ValueNotifier(false);
  final TextEditingController userController =
      TextEditingController(text: "Gooit Admin");
  final TextEditingController emailController =
      TextEditingController(text: "gooit.admin@gmail.com");
  final TextEditingController passwordController =
      TextEditingController(text: "admin123");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    userController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final AuthController _authController = AuthController();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      LoadingScreen.instance().show(context: context, text: "Signing Up...");
      try {
        final goRouter = GoRouter.of(context);

        final statusCode = await _authController.signup(
          userController.text,
          emailController.text,
          passwordController.text,
        );

        if (statusCode == 201) {
          LoadingScreen.instance()
              .show(context: context, text: "Signed Up Successfully");
          await Future.delayed(const Duration(seconds: 1));
          LoadingScreen.instance().hide();
          goRouter.pushNamed(AppRoutes.signIn.name);
        } else {
          LoadingScreen.instance().hide();
          LoadingScreen.instance().show(
              context: context,
              text: "Sign Up failed. Please check another email.");
          await Future.delayed(const Duration(seconds: 1));
          LoadingScreen.instance().hide();

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text('Sign Up failed. Please check another email.')),
          // );
        }
      } catch (e) {
        LoadingScreen.instance().hide();
        LoadingScreen.instance().show(
            context: context, text: "An error occurred. Please try again.");
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
        print("Error during sign up: $e");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('An error occurred. Please try again.')),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    // final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .3,
                child: Text(
                  "Join Gooit Today 👤",
                  style: context.hm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              FadeInSlide(
                duration: .4,
                child: Text(
                  "Join Gooit, Your Gateway to Smart Living.",
                  style: context.tm,
                ),
              ),
              const SizedBox(height: 25),
              FadeInSlide(
                duration: .5,
                child: Text(
                  "Username",
                  style: context.tm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              FadeInSlide(
                duration: .5,
                child: UserField(controller: userController),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .5,
                child: Text(
                  "Email",
                  style: context.tm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              FadeInSlide(
                duration: .5,
                child: EmailField(controller: emailController),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .6,
                child: Text(
                  "Password",
                  style: context.tm!.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              FadeInSlide(
                duration: .6,
                child: PasswordField(controller: passwordController),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .7,
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
                    RichTwoPartsText(
                      text1: "I agree to Smartome ",
                      text2: "Terms and Conditions.",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                duration: .8,
                child: RichTwoPartsText(
                  text1: "Already have an account? ",
                  text2: "Sign In",
                  onTap: () {
                    context.pushReplacementNamed(AppRoutes.signIn.name);
                  },
                ),
              ),
              const SizedBox(height: 30),
              // FadeInSlide(
              //   duration: .9,
              //   child: Row(
              //     children: [
              //       const Expanded(
              //           child: Divider(
              //         thickness: .3,
              //       )),
              //       Text(
              //         "   or   ",
              //         style: context.tm,
              //       ),
              //       const Expanded(
              //           child: Divider(
              //         thickness: .3,
              //       )),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 20),
              // FadeInSlide(
              //   duration: 1.0,
              //   child: LoginButton(
              //     icon: Brand(Brands.google, size: 25),
              //     text: "Continue with Google",
              //     onPressed: () {},
              //   ),
              // ),
              // SizedBox(height: height * 0.02),
              // FadeInSlide(
              //   duration: 1.1,
              //   child: LoginButton(
              //     icon: Icon(
              //       Icons.apple,
              //       color: isDark ? Colors.white : Colors.black,
              //     ),
              //     text: "Continue with Apple",
              //     onPressed: () {},
              //   ),
              // ),
              // SizedBox(height: height * 0.02),
              // FadeInSlide(
              //   duration: 1.2,
              //   child: LoginButton(
              //     icon: Brand(Brands.facebook, size: 25),
              //     text: "Continue with Facebook",
              //     onPressed: () {},
              //   ),
              // ),
              // SizedBox(height: height * 0.02),
              // FadeInSlide(
              //   duration: 1.3,
              //   child: LoginButton(
              //     icon: Brand(Brands.twitter, size: 25),
              //     text: "Continue with Twitter",
              //     onPressed: () {},
              //   ),
              // ),
              // SizedBox(height: height * 0.01),
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
              top: BorderSide(width: .2, color: Colors.white),
            ),
          ),
          child: FilledButton(
            onPressed: _signUp,
            style: FilledButton.styleFrom(
                fixedSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.seedColor),
            child: const Text(
              "Sign Up",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
    );
  }
}
