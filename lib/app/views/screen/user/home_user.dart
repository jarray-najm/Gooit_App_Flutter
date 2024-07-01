import 'package:goo_it/utils/common/app_colors.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'line_view.dart';
import 'profile_view.dart';
import 'scan_view.dart';
import 'station_view.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const ScanView(),
    const LineView(),
    const StationView(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final height = size.height;
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Card(
        elevation: 1,
        surfaceTintColor: AppColors.seedColor,
        // color: isDark ? AppColors.seedColor : Colors.white,
        margin: const EdgeInsets.only(top: 0, bottom: 5, left: 10, right: 10),
        child: SalomonBottomBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.qr_code_scanner),
              title: const Text('Scanner'),
              selectedColor:
                  isDark ? AppColors.whiteColor : AppColors.seedColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.route_rounded),
              title: const Text('Lines'),
              selectedColor:
                  isDark ? AppColors.whiteColor : AppColors.seedColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.fmd_good_sharp),
              title: const Text('Stations'),
              selectedColor:
                  isDark ? AppColors.whiteColor : AppColors.seedColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Profile'),
              selectedColor:
                  isDark ? AppColors.whiteColor : AppColors.seedColor,
            ),
          ],
        ),
      ),
    );
  }
}
