import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goo_it/app/controllers/admin_controller.dart';
import 'package:goo_it/utils/common/text_style_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AdminController _adminService = AdminController();
  double _sumOfPayments = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSumOfPayments();
  }

  Future<void> _fetchSumOfPayments() async {
    try {
      double sumOfPayments = await _adminService.getSumOfPayments();
      setState(() {
        _sumOfPayments = sumOfPayments;
        _isLoading = false;
      });
    } catch (e) {
      // setState(() {
      //   _isLoading = false;
      //   _errorMessage = 'Failed to load sum of payments: $e';
      // });
    }
  }

  Future<void> _logout() async {
    final goRouter = GoRouter.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    goRouter.go("/signIn");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text('Error: $_errorMessage'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FadeInSlide(
                            duration: 1,
                            direction: FadeSlideDirection.btt,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  image: const DecorationImage(
                                    image:
                                        AssetImage("assets/images/card3bg.jpg"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sum of All Payments TND',
                                      style: context.hm!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ' $_sumOfPayments',
                                          style: context.hl!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 60),
                                  ],
                                ),
                              ),
                            )),
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
            onPressed: _logout,
            style: FilledButton.styleFrom(
                fixedSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.seedColor),
            child: const Text(
              "Log Out",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, VoidCallback onPressed,
      {Color? color}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          fixedSize: const Size(double.infinity, 50),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w900, color: AppColors.whiteColor),
        ),
      ),
    );
  }
}
