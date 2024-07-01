import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:goo_it/utils/common/app_colors.dart';
import '../../../../utils/common/text_style_ext.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String text;
  const LoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final brightness = MediaQuery.platformBrightnessOf(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(.05),
        side: BorderSide(color: Colors.grey.shade800, width: .1),
        fixedSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              )),
          Align(alignment: Alignment.centerLeft, child: icon),
        ],
      ),
    );
  }
}

class RichTwoPartsText extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback onTap;
  const RichTwoPartsText({
    super.key,
    required this.text1,
    required this.text2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: context.tm,
        text: text1,
        children: [
          TextSpan(
            text: text2,
            style: context.tm
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey.withOpacity(.1),
        hintText: "Email",
        prefixIcon:
            const Icon(Icons.email, size: 20, color: AppColors.greyColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  const PasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey.withOpacity(.1),
        hintText: "Password",
        prefixIcon:
            const Icon(Icons.lock, size: 20, color: AppColors.greyColor),
        suffixIcon: const Icon(
          Icons.visibility_off,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}

class UserField extends StatelessWidget {
  final TextEditingController controller;
  const UserField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blueGrey.withOpacity(.1),
        hintText: "Username",
        prefixIcon:
            const Icon(Icons.person, size: 20, color: AppColors.greyColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    );
  }
}
