import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/pc_item.dart';
import '../models/support_item.dart';
import '../models/repair_log.dart';

/// Service manajemen local database berbasis Hive Community Edition (Hive CE)
/// Menggunakan 3 box Hive terpisah:
/// 1. 'pc_box'      : Manajemen unit PC & spesifikasi
/// 2. 'support_box' : Inventaris barang pendukung laboratorium
/// 3. 'log_box'     : Riwayat log perbaikan oleh teknisi
class HiveDatabaseService {
  static final HiveDatabaseService instance = HiveDatabaseService._internal();
  HiveDatabaseService._internal();

  static const String pcBoxName = 'pc_box';
  static const String supportBoxName = 'support_box';
  static const String logBoxName = 'log_box';

  late Box _pcBox;
  late Box _supportBox;
  late Box _logBox;

  bool _initialized = false;

  Box get pcBox => _pcBox;
  Box get supportBox => _supportBox;
  Box get logBox => _logBox;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _pcBox = await Hive.openBox(pcBoxName);
    _supportBox = await Hive.openBox(supportBoxName);
    _logBox = await Hive.openBox(logBoxName);
    _initialized = true;

    // Inisialisasi data default awal jika box kosong
    await _seedInitialDataIfNeeded();
  }

  Future<void> _seedInitialDataIfNeeded() async {
    if (_pcBox.isEmpty) {
      final now = DateTime.now();
      final initialPCs = [
        PCItem(
          id: 'pc_1',
          pcNumber: 'PC-01',
          processor: 'Intel Core i5-12400',
          ram: '16 GB DDR4',
          status: 'Normal',
          updatedAt: now,
          notes: 'Posisi meja baris depan kiri',
        ),
        PCItem(
          id: 'pc_2',
          pcNumber: 'PC-02',
          processor: 'Intel Core i5-12400',
          ram: '16 GB DDR4',
          status: 'Normal',
          updatedAt: now,
          notes: 'Posisi meja baris depan tengah',
        ),
        PCItem(
          id: 'pc_3',
          pcNumber: 'PC-03',
          processor: 'AMD Ryzen 5 5600G',
          ram: '16 GB DDR4',
          status: 'Normal',
          updatedAt: now,
          notes: 'Posisi meja baris depan kanan',
        ),
        PCItem(
          id: 'pc_4',
          pcNumber: 'PC-04',
          processor: 'Intel Core i3-10100',
          ram: '8 GB DDR4',
          status: 'Rusak',
          updatedAt: now,
          notes: 'Power supply drop, mati saat render',
        ),
      ];

      for (final pc in initialPCs) {
        await _pcBox.put(pc.id, pc.toMap());
      }
    }

    if (_supportBox.isEmpty) {
      final now = DateTime.now();
      final initialSupports = [
        SupportItem(
          id: 'sup_1',
          name: 'Switch Gigabit 24-Port',
          qty: 2,
          condition: 'Baik',
          location: 'Rak Server Utama',
          updatedAt: now,
        ),
        SupportItem(
          id: 'sup_2',
          name: 'Proyektor Epson HDMI',
          qty: 1,
          condition: 'Baik',
          location: 'Langit-langit Tengah',
          updatedAt: now,
        ),
        SupportItem(
          id: 'sup_3',
          name: 'UPS ICA 1200VA',
          qty: 4,
          condition: 'Perlu Cek',
          location: 'Meja Instruktur & Server',
          updatedAt: now,
        ),
        SupportItem(
          id: 'sup_4',
          name: 'Kabel LAN Tester Digital',
          qty: 2,
          condition: 'Baik',
          location: 'Lemari Toolkit Teknisi',
          updatedAt: now,
        ),
      ];

      for (final sup in initialSupports) {
        await _supportBox.put(sup.id, sup.toMap());
      }
    }

    if (_logBox.isEmpty) {
      final now = DateTime.now();
      final initialLogs = [
        RepairLog(
          id: 'log_1',
          target: 'PC-04',
          issue: 'PC mati total tiba-tiba saat beban kerja berat',
          action: 'Pemeriksaan PSU dan kabel power internal, butuh pergantian unit PSU',
          technician: 'Rian Pratama',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        RepairLog(
          id: 'log_2',
          target: 'Switch Gigabit 24-Port',
          issue: 'Port LAN 7 dan 8 tidak mendeteksi koneksi',
          action: 'Pembersihan socket pin RJ45 dan reset konfigurasi switch',
          technician: 'Budi Santoso',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      for (final l in initialLogs) {
        await _logBox.put(l.id, l.toMap());
      }
    }
  }

  // --- PC ITEM OPERATIONS ---
  List<PCItem> getAllPCs() {
    final list = <PCItem>[];
    for (var key in _pcBox.keys) {
      final val = _pcBox.get(key);
      if (val is Map) {
        list.add(PCItem.fromMap(val, id: key.toString()));
      }
    }
    list.sort((a, b) => a.pcNumber.compareTo(b.pcNumber));
    return list;
  }

  Future<void> savePC(PCItem pc) async {
    await _pcBox.put(pc.id, pc.toMap());
  }

  Future<void> togglePCStatus(String id) async {
    final raw = _pcBox.get(id);
    if (raw is Map) {
      final pc = PCItem.fromMap(raw, id: id);
      final newStatus = pc.isNormal ? 'Rusak' : 'Normal';
      pc.status = newStatus;
      pc.updatedAt = DateTime.now();
      await _pcBox.put(id, pc.toMap());
    }
  }

  Future<void> deletePC(String id) async {
    await _pcBox.delete(id);
  }

  // --- SUPPORT ITEM OPERATIONS ---
  List<SupportItem> getAllSupportItems() {
    final list = <SupportItem>[];
    for (var key in _supportBox.keys) {
      final val = _supportBox.get(key);
      if (val is Map) {
        list.add(SupportItem.fromMap(val, id: key.toString()));
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<void> saveSupportItem(SupportItem item) async {
    await _supportBox.put(item.id, item.toMap());
  }

  Future<void> updateSupportQty(String id, int delta) async {
    final raw = _supportBox.get(id);
    if (raw is Map) {
      final item = SupportItem.fromMap(raw, id: id);
      item.qty = (item.qty + delta).clamp(0, 9999);
      item.updatedAt = DateTime.now();
      await _supportBox.put(id, item.toMap());
    }
  }

  Future<void> deleteSupportItem(String id) async {
    await _supportBox.delete(id);
  }

  // --- REPAIR LOG OPERATIONS ---
  List<RepairLog> getAllRepairLogs() {
    final list = <RepairLog>[];
    for (var key in _logBox.keys) {
      final val = _logBox.get(key);
      if (val is Map) {
        list.add(RepairLog.fromMap(val, id: key.toString()));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveRepairLog(RepairLog log) async {
    await _logBox.put(log.id, log.toMap());
  }

  Future<void> deleteRepairLog(String id) async {
    await _logBox.delete(id);
  }
}
