import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/AdminPanel/Screens/FinanceReports/FinanceReportScreen/FeereportHtmlshowScreen.dart';
import 'package:digivity_admin_app/AuthenticationUi/Loader.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Helpers/GlobalSearch/StudentGlobalSearchHelper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomNavForGlobalSearch extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final dynamic? studentId;

  const BottomNavForGlobalSearch({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.studentId,
  });

  @override
  State<BottomNavForGlobalSearch> createState() =>
      _BottomNavForGlobalSearchState();
}

class _BottomNavForGlobalSearchState extends State<BottomNavForGlobalSearch> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant BottomNavForGlobalSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _scrollToSelected(widget.currentIndex);
    }
  }

  void _scrollToSelected(int index) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Decide how many tabs should roughly fit on screen
    int visibleTabs = screenWidth < 500 ? 3 : 5;

    // Dynamic tab width based on screen size
    double tabWidth = screenWidth / visibleTabs;

    // Calculate scroll offset
    double offset = (tabWidth * index) - (screenWidth / 2) + (tabWidth / 2);

    // Ensure offset stays within scroll limits
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }


  late final List<Map<String, dynamic>> tabs = [
    {"key": '👨‍🎓 Student Info', "reports":"no","reporttype":"no","titleText":""},
    {"key": '💰 Fee Info', "reports":"yes","reporttype":"feeInformation","titleText":"Student Fee Information"},
    {"key": '📅 Attendance Info', "reports":"yes","reporttype":"attendanceinformation","titleText":"Student Attendance Information"},
   ];

  Future<void> getReportData(dynamic studentId, String reportType,String titleText) async {
    showLoaderDialog(context);
    try{
      String? htmlData =await StudentGlobalSearchHelper().apiGetStudentDataGlobalSearch(studentId, reportType);
      if (htmlData != null && htmlData.isNotEmpty) {
        hideLoaderDialog(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeereportHtmlshowScreen(
              HtmlViewData: htmlData,
              appbartext: "${titleText}",
            ),
          ),
        );
      } else {
        hideLoaderDialog(context);
        showBottomMessage(context, "No report data found", true);
      }
    }catch(e){
      hideLoaderDialog(context);
      showBottomMessage(context, "${e}", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 evenly spread tabs
            children: List.generate(tabs.length, (index) {
              bool isSelected = widget.currentIndex == index;
              return Expanded( // 👈 makes each tab equal width
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      widget.onTabSelected(index);

                      if (tabs[index]["reports"] == "yes") {
                        try {
                          await getReportData(
                            widget.studentId,
                            tabs[index]["reporttype"],
                            tabs[index]["titleText"],
                          );
                        } catch (e) {
                          showBottomMessage(context, "$e", true);
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? uiTheme.appBarColor ?? Colors.blueAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabs[index]["key"],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

      ),
    );
  }
}
