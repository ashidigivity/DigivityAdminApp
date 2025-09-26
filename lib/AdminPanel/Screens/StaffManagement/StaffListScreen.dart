import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/AdminPanel/Models/StaffModels/StaffModel.dart';
import 'package:digivity_admin_app/AdminPanel/Screens/StaffManagement/StaffListBottomSheet.dart';
import 'package:digivity_admin_app/AuthenticationUi/Loader.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/BackgrounWeapper.dart';
import 'package:digivity_admin_app/Components/InputField.dart';
import 'package:digivity_admin_app/Components/SimpleAppBar.dart';
import 'package:digivity_admin_app/Providers/StaffDataProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({Key? key}) : super(key: key);

  @override
  State<StaffListScreen> createState() => _StaffListScreen();
}

class _StaffListScreen extends State<StaffListScreen> {
  final TextEditingController _staffSearchController = TextEditingController();
  List<Map<String, dynamic>> _originalList = [];
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _staffSearchController.addListener(_filterStaffList);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final staffs = Provider.of<StaffDataProvider>(
          context,
          listen: false,
        ).staffs;
        _updateStaffList(staffs);
      } catch (e) {
        showBottomMessage(context, "${e}", true);
      }
    });
  }

  void _updateStaffList(List<StaffModel> staffs) {
    final mappedList = _mapStaffList(staffs);
    setState(() {
      _originalList = mappedList;
      _filteredList = mappedList;
    });
  }

  List<Map<String, dynamic>> _mapStaffList(List<StaffModel> staffs) {
    return staffs.map((staff) {
      return {
        'profile_img': staff.profileImg ?? '',
        'profession': staff.profession ?? '',
        'staff_type': staff.staffType ?? '',
        'department': staff.department ?? '',
        'designation': staff.designation ?? '',
        'contact_no': staff.contactNo ?? '',
        'full_name': staff.fullName ?? '',
        'father_name': staff.fatherName ?? '',
        'address': staff.address ?? '',
        'staff_no': staff.staffNo ?? '',
        'status': staff.status,
        'staff_id': staff.dbId,
      };
    }).toList();
  }

  void _filterStaffList() {
    try {
      final query = _staffSearchController.text.toLowerCase();
      setState(() {
        _filteredList = _originalList.where((staff) {
          return (staff['full_name']?.toLowerCase().contains(query) ?? false) ||
              (staff['staff_no']?.toLowerCase().contains(query) ?? false) ||
              (staff['contact_no']?.toLowerCase().contains(query) ?? false) ||
              (staff['address']?.toLowerCase().contains(query) ?? false);
        }).toList();
      });
    } catch (e) {
      showBottomMessage(context, "${e}", true);
      _filteredList = [];
    }
  }

  @override
  void dispose() {
    _staffSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SimpleAppBar(titleText: "Search Staff List", routeName: 'back'),
      ),
      body: BackgroundWrapper(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomTextField(
                  label: 'Search Staff',
                  hintText: 'Search Staff Here',
                  controller: _staffSearchController,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<StaffDataProvider>(
                    builder: (context, staffProvider, _) {
                      final updatedList = _mapStaffList(staffProvider.staffs);
                      final filtered = _staffSearchController.text.isEmpty
                          ? updatedList
                          : updatedList.where((staff) {
                        final query = _staffSearchController.text.toLowerCase();
                        return (staff['full_name']?.toLowerCase().contains(query) ?? false) ||
                            (staff['staff_no']?.toLowerCase().contains(query) ?? false) ||
                            (staff['contact_no']?.toLowerCase().contains(query) ?? false) ||
                            (staff['address']?.toLowerCase().contains(query) ?? false);
                      }).toList();

                      return filtered.isNotEmpty
                          ? ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final staff = filtered[index];
                          return _modernStaffCard(staff);
                        },
                      )
                          : const Center(child: Text("No staff found"));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Modern Staff Card
  Widget _modernStaffCard(Map<String, dynamic> staff) {
    return GestureDetector(
      onTap: () {
        showStaffListBottomSheet(
          context,
          staff['staff_id'] ?? 0,
          staff['full_name'] ?? 'Unknown',
          staff['staff_no'].toString(),
          staff['contact_no'].toString(),
          staff['status'],
              (updatedList) => _updateStaffList(updatedList),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              PopupNetworkImage(
                imageUrl: staff['profile_img'],
                radius: 32,
              ),
              const SizedBox(width: 14),
              // Staff Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            staff['full_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: staff['status'] == 1
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            staff['status'] == 1 ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: staff['status'] == 1 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoRow(Icons.badge, "ID: ${staff['staff_id']}"),
                    _infoRow(Icons.confirmation_number, "Staff No: ${staff['staff_no']}"),
                    _infoRow(Icons.work, "Profession: ${staff['profession']}"),
                    _infoRow(Icons.account_tree, "Designation: ${staff['designation']}"),
                    _infoRow(Icons.apartment, "Department: ${staff['department']}"),
                    _infoRow(Icons.phone, "Mobile: ${staff['contact_no']}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Helper Widget for Info Row
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
