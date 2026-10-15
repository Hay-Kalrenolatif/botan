class SupportItem {
  String id;
  String name;
  int qty;
  String condition; // 'Baik', 'Rusak', 'Perlu Cek'
  String? location;
  DateTime updatedAt;

  SupportItem({
    required this.id,
    required this.name,
    required this.qty,
    this.condition = 'Baik',
    this.location,
    required this.updatedAt,
  });

  bool get isGood => condition.toLowerCase() == 'baik';
  bool get isBroken => condition.toLowerCase() == 'rusak';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'qty': qty,
        'condition': condition,
        if (location != null) 'location': location,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SupportItem.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final rawDate = map['updatedAt'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return SupportItem(
      id: id ?? map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? 'Barang',
      qty: (map['qty'] as num?)?.toInt() ?? 1,
      condition: map['condition']?.toString() ?? 'Baik',
      location: map['location']?.toString(),
      updatedAt: parsedDate,
    );
  }
}
