import 'dart:async';
import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/Loader.dart';
import 'package:digivity_admin_app/Components/NotificationBadge.dart';
import 'package:digivity_admin_app/Providers/DashboardProvider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppBarComponent extends StatefulWidget {
  final String appbartitle;

  const AppBarComponent({Key? key, required this.appbartitle})
    : super(key: key);

  @override
  State<AppBarComponent> createState() => _AppBarComponentState();
}

class _AppBarComponentState extends State<AppBarComponent> {
  String logo = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
    });
  }

  Future<void> getUserData() async {
    try {
      logo = await SharedPrefHelper.getPreferenceValue('profile_image');
      username = await SharedPrefHelper.getPreferenceValue('name');
    } catch (e) {
      showBottomMessage(context, "${e}", true);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);

    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: uiTheme.appBarColor ?? Color(0xFF1E88E5),
      elevation: 4,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            Text(
              widget.appbartitle.length > 9
                  ? '${widget.appbartitle.substring(0, 6)}...'
                  : widget.appbartitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: uiTheme.appbarIconColor ?? Colors.white,
              ),
            ),
            Spacer(),

            // Notification Icons
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: uiTheme.appbarIconColor ?? Colors.white,
                    size: 20,
                  ),
                  onPressed: () async {
                    final dashboardProvider = Provider.of<DashboardProvider>(
                      context,
                      listen: false,
                    );
                    final uiThemeProvider = Provider.of<UiThemeProvider>(
                      context,
                      listen: false,
                    );

                    await dashboardProvider.fetchDashboardData(context);
                    await uiThemeProvider.loadThemeSettingsFromApi(
                      context,
                    ); // <- This refreshes UI colors
                  },
                ),
                SizedBox(width: 15),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: uiTheme.appbarIconColor ?? Colors.white,
                      size: 22,
                    ),
                    NotificationBadge(),
                  ],
                ),
              ],
            ),
            SizedBox(width: 16),
            // Profile + Username
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                onTap: () {
                  // context.pushNamed('select-another-user');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PopupNetworkImage(
                      radius: 13,
                      imageUrl: (logo != null && logo!.isNotEmpty)
                          ? logo!
                          : 'assets/logos/default_profile.png',
                    ),
                    SizedBox(width: 8),
                    Text(
                      username.isNotEmpty
                          ? (username.length > 10
                                ? username.substring(0, 8) + "..."
                                : username)
                          : 'Hello',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
