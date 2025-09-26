class ModuleData {
  final List<ModuleItem> quickAction;
  final List<ModuleItem> reports;

  ModuleData({
    required this.quickAction,
    required this.reports,
  });

  factory ModuleData.fromJson(Map<String, dynamic> json) {
    return ModuleData(
      quickAction: (json['quick-action'] as List<dynamic>?)
          ?.map((e) => ModuleItem.fromJson(e as Map<String, dynamic>))
          .toList()
          ?? [],
      reports: (json['reports'] as List<dynamic>?)
          ?.map((e) => ModuleItem.fromJson(e as Map<String, dynamic>))
          .toList()
          ?? [],
    );
  }
}

class ModuleItem {
  final String moduleId;
  final String moduleText;
  final String moduleSequence;
  final String category;

  ModuleItem({
    required this.moduleId,
    required this.moduleText,
    required this.moduleSequence,
    required this.category,
  });

  factory ModuleItem.fromJson(Map<String, dynamic> json) {
    return ModuleItem(
      moduleId: json['module_id'] ?? '',
      moduleText: json['module_text'] ?? '',
      moduleSequence: json['module_sequence'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
