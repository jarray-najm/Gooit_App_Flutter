import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_routes.dart';
import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';

class GetStartedView extends StatefulWidget {
  const GetStartedView({super.key});

  @override
  State<GetStartedView> createState() => _GetStartedViewState();
}

class _GetStartedViewState extends State<GetStartedView> {
  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            FadeInSlide(
              duration: 1,
              direction: FadeSlideDirection.ttb,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0), // Border radius
                ),
                child: const Image(
                  image: AssetImage(
                      'assets/images/gooit.png'), // Replace with your asset image path
                ),
              ),
            ),
            const Spacer(),
            FadeInSlide(
              duration: .5,
              child: Text(
                "Let's Get Started!",
                style: theme.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: height * 0.015),
            const FadeInSlide(
              duration: .6,
              child: Text(
                "Let's dive in into your account",
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            const Spacer(),
            FadeInSlide(
              duration: 1.1,
              direction: FadeSlideDirection.btt,
              child: FilledButton(
                onPressed: () => context.push(AppRoutes.signUp.path),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.seedColor,
                  fixedSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: AppColors.whiteColor),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            FadeInSlide(
              duration: 1.2,
              child: FilledButton(
                onPressed: () => context.push(AppRoutes.signIn.path),
                style: FilledButton.styleFrom(
                  fixedSize: const Size.fromHeight(50),
                  backgroundColor: isDark
                      ? AppColors.textFieldColor
                      : AppColors.textFieldColor,
                ),
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.whiteColor : AppColors.seedColor,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const FadeInSlide(
              duration: 1.0,
              direction: FadeSlideDirection.btt,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "   -   ",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Terms of Service",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
