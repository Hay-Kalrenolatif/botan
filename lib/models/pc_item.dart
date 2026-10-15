class PCItem {
  String id;
  String pcNumber;
  String processor;
  String ram;
  String status; // 'Normal' atau 'Rusak'
  DateTime updatedAt;
  String? notes;

  PCItem({
    required this.id,
    required this.pcNumber,
    required this.processor,
    required this.ram,
    this.status = 'Normal',
    required this.updatedAt,
    this.notes,
  });

  bool get isNormal => status.toLowerCase() == 'normal';

  Map<String, dynamic> toMap() => {
        'id': id,
        'pcNumber': pcNumber,
        'processor': processor,
        'ram': ram,
        'status': status,
        'updatedAt': updatedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  factory PCItem.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final rawDate = map['updatedAt'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return PCItem(
      id: id ?? map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      pcNumber: map['pcNumber']?.toString() ?? 'PC-01',
      processor: map['processor']?.toString() ?? 'Intel Core i5',
      ram: map['ram']?.toString() ?? '16 GB',
      status: map['status']?.toString() ?? 'Normal',
      updatedAt: parsedDate,
      notes: map['notes']?.toString(),
    );
  }
}
