import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/AdminPanel/Models/GlobalSearchModel/StudentInformationForGlobalSearch.dart';
import 'package:digivity_admin_app/AdminPanel/Screens/StudentsManagement/StudentGlobalSearch/BottomNavForGlobalSearch.dart';
import 'package:digivity_admin_app/Components/BackgrounWeapper.dart';
import 'package:digivity_admin_app/Components/SimpleAppBar.dart';
import 'package:digivity_admin_app/Helpers/GlobalSearch/StudentGlobalSearchHelper.dart';
import 'package:digivity_admin_app/Helpers/launchAnyUrl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// For mapIndexed

class StudentInformation extends StatefulWidget {
  final dynamic studentId;

  const StudentInformation({super.key, required this.studentId});

  @override
  State<StudentInformation> createState() => _StudentInformationState();
}

class _StudentInformationState extends State<StudentInformation>
    with TickerProviderStateMixin {
  StudentInformationForGlobalSearch? studentInfo;
  bool isStudentInfo = false;
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    getStudentInformation(widget.studentId);
  }

  // 🔹 API CALL FUNCTION
  Future<void> getStudentInformation(int studentId) async {
    try {
      final response = await StudentGlobalSearchHelper()
          .getStudentListForGlobalSearch(studentId);

      if (response != null) {
        studentInfo = response as StudentInformationForGlobalSearch?;
        isStudentInfo = true;

        // Initialize TabController with 7 tabs
        _tabController = TabController(length: 10, vsync: this);

        setState(() {});
      }
    } catch (e) {
      debugPrint("Error fetching student info: $e");
    }
  }

  @override
  void dispose() {
    if (isStudentInfo) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Provider.of<UiThemeProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SimpleAppBar(
          titleText: "Student Complete Information",
          routeName: "back",
        ),
      ),
      body: BackgroundWrapper(
        child: isStudentInfo
            ? Column(
                children: [
                  // Header + TabBar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            indicatorPadding: const EdgeInsets.symmetric(
                              horizontal: -10,
                              vertical: 5,
                            ),
                            indicator: BoxDecoration(
                              color: uiTheme.appBarColor ?? Colors.blueAccent,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            indicatorColor: Colors.transparent,
                            dividerColor: Colors.transparent,
                            labelColor: uiTheme.appbarIconColor ?? Colors.white,
                            unselectedLabelColor: Colors.black87,
                            tabs: const [
                              Tab(text: 'Student Info'),
                              Tab(text: 'Academic Info'),
                              Tab(text: 'Fee Info'),
                              Tab(text: 'Father Info'),
                              Tab(text: 'Mother Info'),
                              Tab(text: 'Address Info'),
                              Tab(text: 'Guardian Info'),
                              Tab(text: 'Emergency Info'),
                              Tab(text: 'Student Documents',),
                              Tab(text: 'Student Commitments Details',)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabContent(
                          "Student Info",
                          studentInfo!.studentPersonalInfo,
                        ),
                        _buildTabContent(
                          "Academic Info",
                          studentInfo!.academicInformation,
                        ),
                        _buildTabContent(
                          "Fee Info",
                          studentInfo!.feeInformation,
                        ),
                        _buildTabContent(
                          "Father Info",
                          studentInfo!.fatherInformation,
                        ),
                        _buildTabContent(
                          "Mother Info",
                          studentInfo!.motherInformation,
                        ),
                        _buildTabContent(
                          "Address Info",
                          studentInfo!.addressInformation,
                        ),
                        _buildTabContent(
                          "Guardian Info",
                          studentInfo!.localGuardianInformation,
                        ),
                        _buildTabContent(
                          "Emergency Info",
                          studentInfo!.emergencyInformation,
                        ),
                        _buildUploadDocsSection(
                          "Student Documents Info",
                          studentInfo!.uploadDocs,
                        ),
                        _buildCommitmentInfoSection(
                          "Student Commitments Info",
                          studentInfo!.cmmitmentDetails,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: isStudentInfo
          ? BottomNavForGlobalSearch(
        currentIndex: _currentIndex,
        studentId: widget.studentId,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      )
          : SizedBox.shrink(), // or null
    );
  }

  // 🔹 Modern tab content with animation
  Widget _buildTabContent(String title, Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),

          // Responsive grid
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              double cardWidth = isWide
                  ? (constraints.maxWidth / 2) - 16
                  : double.infinity;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: data.entries.map((entry) {
                  String label = entry.key
                      .split('_')
                      .map(
                        (word) => word.isNotEmpty
                            ? '${word[0].toUpperCase()}${word.substring(1)}'
                            : '',
                      )
                      .join(' ');

                  return Container(
                    width: entry.key == "profile_image"
                        ? double.infinity
                        : cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: entry.key == "profile_image"
                        ? Column(
                            children: [
                              Text(
                                "Profile Image",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PopupNetworkImage(
                                radius: 100,
                                imageUrl: entry.value,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }


  /// For Student Documents
  Widget _buildUploadDocsSection(String title, List<Map<String, dynamic>> docs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              double cardWidth = isWide
                  ? (constraints.maxWidth / 2) - 16
                  : double.infinity;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: docs.map((doc) {
                  String documentName = doc["document_name"] ?? "N/A";
                  String documentFile = doc["document_file"] ?? "";
                  bool hasFile = documentFile.isNotEmpty;

                  return Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        hasFile
                            ? GestureDetector(
                          onTap: () {
                         openFile(documentFile);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              documentFile,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 120,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        )
                            : Container(
                          height: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            "No file uploaded",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }



 /// For Student Commitments


  Widget _buildCommitmentInfoSection(String title, List<Map<String, dynamic>> commitments) {
    return commitments.isNotEmpty
        ? SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              double cardWidth = isWide
                  ? (constraints.maxWidth / 2) - 16
                  : double.infinity;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: commitments.map((commitment) {
                  String type = commitment["commitment_type"] ?? "N/A";
                  String date = commitment["commitment_date"] ?? "N/A";
                  String? months = commitment["fee_months"];
                  String? remark = commitment["remark"];

                  return Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("⏰ ", style: TextStyle(fontSize: 18)),
                            Expanded(
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: Colors.blueAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        if (months != null && months.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.payments,
                                  color: Colors.green, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Fee Months: ${months.toUpperCase()}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (remark != null && remark.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.comment,
                                  color: Colors.orangeAccent, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  remark,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    )
        : const Center(child: Text("No Data Found"));
  }

}
