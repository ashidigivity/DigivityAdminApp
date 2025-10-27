import 'package:digivity_admin_app/AdminPanel/CustomGraphComponent/Bargraph.dart';
import 'package:digivity_admin_app/AdminPanel/CustomGraphComponent/PieChart.dart';
import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/AppBarComponent.dart';
import 'package:digivity_admin_app/Components/BackgrounWeapper.dart';
import 'package:digivity_admin_app/Components/BottomNavigation.dart';
import 'package:digivity_admin_app/Components/CardContainer.dart';
import 'package:digivity_admin_app/Components/SideBar.dart';
import 'package:digivity_admin_app/Components/SliderCarouselWidget.dart';
import 'package:digivity_admin_app/Providers/DashboardProvider.dart';
import 'package:digivity_admin_app/helpers/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}



class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).fetchDashboardData(context);
      final uiThemeProvider = Provider.of<UiThemeProvider>(
        context,
        listen: false,
      ).loadThemeSettingsFromApi(context);
      await PermissionService.requestNotificationPermission(context);
      await PermissionService.requestDeviceLocationPermission(context);
    });


  }

  void _onBottomBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final uiTheme = Provider.of<UiThemeProvider>(context);

    if (dashboardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      drawer: Sidebar(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarComponent(appbartitle: "Dashboard"),
      ),
      body: BackgroundWrapper(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  /// Slider
                  SliderCarouselWidget(
                    data: dashboardProvider.sliderdata
                        .map((item) => {
                      'key': item.key,
                      'value': item.value.toString(),
                    })
                        .toList(),
                  ),




                  ///   Student Attendance Summary Pie Chart
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Student Attendance Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Piechart(
                          sections: dashboardProvider.labelsofstudentattendance,
                          values: dashboardProvider.coutofstudentattendance,
                          colors: uiTheme.graphColors,
                        ),
                      ],
                    ),
                  ),

                  ///   Teacher Attendance Summary Pie Chart
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Teacher Attendance Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Piechart(
                          sections: dashboardProvider.labelsofattendance,
                          values: dashboardProvider.coutofattendance,
                          colors: uiTheme.graphColors,
                        ),
                      ],
                    ),
                  ),

                  /// Bar Graph
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Classwise Gender Count",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Bargraph(
                            stackLabels: ['Male', 'Female'],
                            labels: dashboardProvider.classStrengthList
                                .map((e) => e.course)
                                .toList(),
                            stackedData: [
                              dashboardProvider.classStrengthList
                                  .map((e) => e.maleCount.toDouble())
                                  .toList(),
                              dashboardProvider.classStrengthList
                                  .map((e) => e.femaleCount.toDouble())
                                  .toList(),
                            ],
                            colors:
                            (uiTheme.graphColors != null &&
                                uiTheme.graphColors!.length >= 2)
                                ? uiTheme.graphColors!
                                : [Color(0xFF028FFB), Color(0xFF04E396)],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Pie Chart
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Paymode Payment Summary",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Piechart(
                          sections: dashboardProvider.paymodeList
                              .map((e) => e.paymode)
                              .toList(),
                          values: dashboardProvider.paymodeList
                              .map((e) => double.tryParse(e.total) ?? 0.0)
                              .toList(),
                          colors: uiTheme.graphColors,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 22,
              right: 15,
              child: FloatingActionButton(
                backgroundColor: uiTheme.appBarColor ?? Colors.blue,
                onPressed: () async {
                  try{
                    context.pushNamed("student-global-search");
                  }catch(e){
                    showBottomMessage(context, "${e}", true);
                  }

                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.search,
                      color: uiTheme.appbarIconColor ?? Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )


      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
