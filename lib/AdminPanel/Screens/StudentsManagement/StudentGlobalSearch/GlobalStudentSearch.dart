import 'dart:async';

import 'package:digivity_admin_app/AdminPanel/Components/SearchBox.dart';
import 'package:digivity_admin_app/AdminPanel/Models/GlobalSearchModel/StudentGlobalSearchModel.dart';
import 'package:digivity_admin_app/AdminPanel/Models/Studdent/StudentGlobalSearch/StudentCardGlobalSearch.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/BackgrounWeapper.dart';
import 'package:digivity_admin_app/Components/SimpleAppBar.dart';
import 'package:digivity_admin_app/Helpers/GlobalSearch/StudentGlobalSearchHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalStudentSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GlobalStudentSearch();
  }
}

class _GlobalStudentSearch extends State<GlobalStudentSearch> {
  late TextEditingController _controller;
  List<StudentGlobalSearchModel> _students = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchStudents(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await StudentGlobalSearchHelper()
          .fetchStudentRecordGlobalSearch(query);
      setState(() {
        _students = response;
        print("Student Length");
        print(_students.length);
      });
    } catch (e) {
      showBottomMessage(context, "$e", true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchStudents(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SimpleAppBar(
          titleText: "Student Global Search",
          routeName: "back",
        ),
      ),
      body: BackgroundWrapper(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SearchBox(
                onChanged: _onSearchChanged,
                controller: _controller,
              ),
              const SizedBox(height: 10),

              // Loading indicator
              if (_isLoading)
                Center( child: const CircularProgressIndicator(),),

              // List of students
              Expanded(
                child: _students.isEmpty
                    ? Center(
                  child: Text(
                    "No students found",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
                    : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];

                    // Staggered scale + fade animation
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: child,
                          ),
                        );
                      },
                      child: InteractiveStudentCard(
                        imageUrl: student.profileImg,
                        studentName: student.studentName,
                        course: student.course,
                        fatherName:student.fatherName,
                        admissionNo: student.admissionNo,
                        studentId: student.studentId,
                      ),
                    );
                  },
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
