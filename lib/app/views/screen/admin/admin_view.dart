import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../../../utils/common/app_colors.dart';

import 'dashboard.dart';

import 'line_page.dart';
import 'station_page.dart';
import 'user_list_view.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const LinesView(),
    const StationsView(),
    const UsersView(),
    const DashboardView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
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
              icon: const Icon(Icons.group_sharp),
              title: const Text('Users'),
              selectedColor:
                  isDark ? AppColors.whiteColor : AppColors.seedColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.space_dashboard_rounded),
              title: const Text('Dashboard'),
              selectedColor:
                  isDark ? AppColors.whiteColor : AppColors.seedColor,
            ),
          ],
        ),
      ),
    );
  }
}
