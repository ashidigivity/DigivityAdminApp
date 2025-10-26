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

      // Always show labels
      showUnselectedLabels: true,

      // Selected/Unselected colors
      selectedItemColor: uiTheme.appbarIconColor ?? Colors.black,
      unselectedItemColor:
      (uiTheme.appbarIconColor ?? Colors.black).withOpacity(0.5), // feeka color

      selectedLabelStyle: TextStyle(
        color: uiTheme.appbarIconColor ?? Colors.black,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        color: (uiTheme.appbarIconColor ?? Colors.black).withOpacity(0.5),
        fontWeight: FontWeight.w400,
      ),

      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: selectedIndex == 0
                ? uiTheme.appbarIconColor ?? Colors.black
                : (uiTheme.appbarIconColor ?? Colors.black).withOpacity(0.5),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: selectedIndex == 1
                ? uiTheme.appbarIconColor ?? Colors.black
                : (uiTheme.appbarIconColor ?? Colors.black).withOpacity(0.5),
          ),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.menu,
            color: selectedIndex == 2
                ? uiTheme.appbarIconColor ?? Colors.black
                : (uiTheme.appbarIconColor ?? Colors.black).withOpacity(0.5),
          ),
          label: 'Menus',
        ),
      ],
    );
  }
}
