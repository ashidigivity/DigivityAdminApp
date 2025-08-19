import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/Components/Menus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  int _getSelectedIndex(String location) {
    if (location.startsWith('/search')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0; // default to home
  }

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      showCustomMenuModal(context);
      return;
    }

    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('profile');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(location);

    final uiTheme = Provider.of<UiThemeProvider>(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: uiTheme.bottomSheetBgColor ?? Colors.white,
      currentIndex: selectedIndex,
      onTap: (index) => _onTap(context, index),

      selectedItemColor: uiTheme.appbarIconColor ?? Colors.black,
      unselectedItemColor: Colors.black,

      // Optional: More styling control
      selectedLabelStyle: TextStyle(
        color: uiTheme.appbarIconColor ?? Colors.white,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        color: uiTheme.appbarIconColor ?? Colors.black,
      ),

      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: uiTheme.appbarIconColor ?? Colors.black),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: uiTheme.appbarIconColor ?? Colors.black),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu, color: uiTheme.appbarIconColor ?? Colors.black),
          label: 'Menus',
        ),
      ],
    );


  }
}
