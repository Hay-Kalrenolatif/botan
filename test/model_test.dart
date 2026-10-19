import 'package:flutter_test/flutter_test.dart';
import 'package:ltrack/models/pc_item.dart';
import 'package:ltrack/models/support_item.dart';
import 'package:ltrack/models/repair_log.dart';

void main() {
  group('PCItem roundtrip', () {
    test('toMap/fromMap preserves all fields', () {
      final now = DateTime(2024, 1, 15, 10, 30, 0);
      final pc = PCItem(
        id: 'pc_1',
        pcNumber: 'PC-01',
        processor: 'Intel Core i5-12400',
        ram: '16 GB DDR4',
        status: 'Normal',
        updatedAt: now,
        notes: 'Catatan test',
      );
      final map = pc.toMap();
      final parsed = PCItem.fromMap(map as Map<dynamic, dynamic>, id: 'pc_1');
      expect(parsed.id, pc.id);
      expect(parsed.pcNumber, pc.pcNumber);
      expect(parsed.processor, pc.processor);
      expect(parsed.ram, pc.ram);
      expect(parsed.status, pc.status);
      expect(parsed.updatedAt, pc.updatedAt);
      expect(parsed.notes, pc.notes);
    });

    test('fromMap uses defaults when fields missing', () {
      final map = <String, dynamic>{};
      final pc = PCItem.fromMap(map as Map<dynamic, dynamic>);
      expect(pc.pcNumber, 'PC-01');
      expect(pc.processor, 'Intel Core i5');
      expect(pc.ram, '16 GB');
      expect(pc.status, 'Normal');
      expect(pc.updatedAt, isNotNull);
      expect(pc.notes, null);
    });
  });

  group('SupportItem roundtrip', () {
    test('preserves all fields', () {
      final now = DateTime(2024, 2, 20, 14, 45, 0);
      final sup = SupportItem(
        id: 'sup_1',
        name: 'Switch',
        qty: 5,
        condition: 'Baik',
        location: 'Rak Utama',
        updatedAt: now,
      );
      final map = sup.toMap();
      final parsed = SupportItem.fromMap(map as Map<dynamic, dynamic>, id: 'sup_1');
      expect(parsed.id, sup.id);
      expect(parsed.name, sup.name);
      expect(parsed.qty, sup.qty);
      expect(parsed.condition, sup.condition);
      expect(parsed.location, sup.location);
      expect(parsed.updatedAt, sup.updatedAt);
    });
  });

  group('RepairLog roundtrip', () {
    test('preserves all fields', () {
      final now = DateTime(2024, 3, 1, 9, 0, 0);
      final log = RepairLog(
        id: 'log_1',
        target: 'PC-04',
        issue: 'Mati total',
        action: 'Ganti PSU',
        technician: 'Rian',
        createdAt: now,
      );
      final map = log.toMap();
      final parsed = RepairLog.fromMap(map as Map<dynamic, dynamic>, id: 'log_1');
      expect(parsed.id, log.id);
      expect(parsed.target, log.target);
      expect(parsed.issue, log.issue);
      expect(parsed.action, log.action);
      expect(parsed.technician, log.technician);
      expect(parsed.createdAt, log.createdAt);
    });
  });
}