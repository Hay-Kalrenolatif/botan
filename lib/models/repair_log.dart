class RepairLog {
  String id;
  String target; // contoh: "PC-04", "Switch Hub 01", "Proyektor Lab A"
  String issue;  // jenis kerusakan
  String action; // tindakan penanganan
  String technician; // nama teknisi
  DateTime createdAt;

  RepairLog({
    required this.id,
    required this.target,
    required this.issue,
    required this.action,
    required this.technician,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'target': target,
        'issue': issue,
        'action': action,
        'technician': technician,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RepairLog.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return RepairLog(
      id: id ?? map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      target: map['target']?.toString() ?? 'PC Lab',
      issue: map['issue']?.toString() ?? 'Kerusakan',
      action: map['action']?.toString() ?? 'Tindakan perbaikan',
      technician: map['technician']?.toString() ?? 'Teknisi Lab',
      createdAt: parsedDate,
    );
  }
}
