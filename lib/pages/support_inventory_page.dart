import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../theme.dart';
import '../models/support_item.dart';
import '../services/hive_database_service.dart';
import '../widgets/common.dart';

class SupportInventoryPage extends StatefulWidget {
  const SupportInventoryPage({super.key});

  @override
  State<SupportInventoryPage> createState() => _SupportInventoryPageState();
}

class _SupportInventoryPageState extends State<SupportInventoryPage> {
  int filterIndex = 0; // 0 = Semua, 1 = Baik, 2 = Rusak / Perlu Cek

  void _showSupportForm(BuildContext context, [SupportItem? existing]) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final qtyCtrl = TextEditingController(text: existing != null ? existing.qty.toString() : '1');
    final locCtrl = TextEditingController(text: existing?.location ?? '');
    String condition = existing?.condition ?? 'Baik';

    void addQty(int delta) {
      final cur = int.tryParse(qtyCtrl.text) ?? 0;
      qtyCtrl.text = (cur + delta).clamp(1, 9999).toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            20,
            22,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.devices_other_rounded, color: yel, size: 22),
                  const SizedBox(width: 10),
                  tx(isEdit ? 'Edit Alat Pendukung' : 'Tambah Inventaris Pendukung', 18, w: FontWeight.w700),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: dec('Nama Barang Non-PC (contoh: Switch Hub 24-Port)', prefix: const Icon(Icons.inventory_2_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final preset in ['Switch Hub 24-Port', 'Proyektor HDMI', 'UPS 1200VA', 'Kabel LAN Cat6 50M', 'Crimping Tool'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: tx(preset, 11, c: yel, w: FontWeight.w600),
                          backgroundColor: a(yel, 0.1),
                          side: BorderSide(color: a(yel, 0.2)),
                          padding: EdgeInsets.zero,
                          onPressed: () => setSheetState(() => nameCtrl.text = preset),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: dec('Jumlah Barang (Unit)', prefix: const Icon(Icons.numbers_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final val in [1, 5, 10])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: tx('+$val', 11, c: const Color.fromARGB(255, 168, 230, 216), w: FontWeight.w600),
                        backgroundColor: a(mint, 0.1),
                        side: BorderSide(color: a(mint, 0.2)),
                        padding: EdgeInsets.zero,
                        onPressed: () => setSheetState(() => addQty(val)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              tx('Kondisi Barang', 12, c: Colors.white60),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final cond in ['Baik', 'Perlu Cek', 'Rusak']) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => condition = cond),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: condition == cond
                                ? a(cond == 'Baik' ? mint : (cond == 'Perlu Cek' ? yel : org), 0.15)
                                : cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: condition == cond
                                  ? (cond == 'Baik' ? mint : (cond == 'Perlu Cek' ? yel : org))
                                  : Colors.white12,
                            ),
                          ),
                          child: Center(
                            child: tx(
                              cond,
                              12,
                              c: condition == cond
                                  ? (cond == 'Baik' ? mint : (cond == 'Perlu Cek' ? yel : org))
                                  : Colors.white70,
                              w: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (cond != 'Rusak') const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                decoration: dec('Lokasi / Tempat Simpan (opsional)', prefix: const Icon(Icons.place_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: btn(isEdit ? 'Perbarui Barang' : 'Simpan', () {
                  final name = nameCtrl.text.trim();
                  final q = int.tryParse(qtyCtrl.text) ?? 1;

                  if (name.isEmpty) {
                    snack(context, 'Masukkan nama barang terlebih dahulu', isError: true);
                    return;
                  }

                  final item = SupportItem(
                    id: existing?.id ?? 'sup_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    qty: q,
                    condition: condition,
                    location: locCtrl.text.trim().isEmpty ? null : locCtrl.text.trim(),
                    updatedAt: DateTime.now(),
                  );

                  HiveDatabaseService.instance.saveSupportItem(item);
                  Navigator.pop(ctx);
                  snack(context, '$name ($q unit) disimpan ke support_box');
                }, icon: Icons.save_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SupportItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: tx('Hapus Alat Pendukung?', 18, w: FontWeight.w700),
        content: tx(
          'Barang "${item.name}" sebanyak ${item.qty} unit akan dihapus dari support_box.',
          14,
          c: Colors.white70,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: tx('Batal', 14, c: Colors.white60),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: org),
            onPressed: () {
              HiveDatabaseService.instance.deleteSupportItem(item.id);
              Navigator.pop(ctx);
              snack(context, '${item.name} dihapus dari inventaris');
            },
            child: tx('Hapus', 14, c: bg, w: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = HiveDatabaseService.instance;

    return ValueListenableBuilder(
      valueListenable: db.supportBox.listenable(),
      builder: (context, box, _) {
        final allItems = db.getAllSupportItems();
        final filtered = allItems.where((item) {
          if (filterIndex == 1) return item.isGood;
          if (filterIndex == 2) return !item.isGood;
          return true;
        }).toList();

        final totalQty = allItems.fold<int>(0, (s, i) => s + i.qty);
        final goodQty = allItems.where((i) => i.isGood).fold<int>(0, (s, i) => s + i.qty);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            tx('Inventaris Pendukung Lab', 22, w: FontWeight.w700, al: TextAlign.center),

            // Filter Tabs
            Seg(
              const ['Semua', 'Kondisi Baik', 'Cek/Rusak'],
              filterIndex,
              (v) => setState(() => filterIndex = v),
            ),

            // Total Counter
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: a(yel, 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.devices_other_rounded, color: yel, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx('Total Inventaris Pendukung', 11, c: Colors.white54),
                        const SizedBox(height: 2),
                        tx('$totalQty Unit Terdata ($goodQty Kondisi Baik)', 15, w: FontWeight.w700, c: Colors.white),
                      ],
                    ),
                  ),
                  btn('Tambah', () => _showSupportForm(context), tonal: true, icon: Icons.add_rounded),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tx('Daftar Perangkat (${filtered.length})', 15, w: FontWeight.w600),
              ],
            ),
            const SizedBox(height: 8),

            for (final item in filtered) _buildSupportCard(context, item),

            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.white24),
                    const SizedBox(height: 10),
                    tx('Belum ada alat pendukung pada filter ini', 13, c: Colors.white38, al: TextAlign.center),
                    const SizedBox(height: 12),
                    btn('+ Tambah Alat Pendukung', () => _showSupportForm(context), tonal: true),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSupportCard(BuildContext context, SupportItem item) {
    final col = item.isGood ? mint : (item.condition == 'Perlu Cek' ? yel : org);

    return Panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: a(col, 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: a(col, 0.25)),
                ),
                child: Center(
                  child: tx('${item.qty}', 14, w: FontWeight.w700, c: col),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tx(item.name, 15, w: FontWeight.w700),
                    const SizedBox(height: 2),
                    tx(
                      item.location != null ? 'Lokasi: ${item.location}' : 'Diperbarui ${fd(item.updatedAt)}',
                      11,
                      c: Colors.white54,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: a(col, 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: tx(item.condition, 11, c: col, w: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white38),
                onPressed: () => _showSupportForm(context, item),
                tooltip: 'Edit item',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white38),
                onPressed: () => _confirmDelete(context, item),
                tooltip: 'Hapus item',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Quantity
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                tx('Kuantitas Barang:', 12, c: Colors.white54),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: Colors.white60),
                  onPressed: () => HiveDatabaseService.instance.updateSupportQty(item.id, -1),
                  tooltip: 'Kurangi 1',
                ),
                tx('${item.qty} unit', 13, w: FontWeight.w700, c: Colors.white),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: mint),
                  onPressed: () => HiveDatabaseService.instance.updateSupportQty(item.id, 1),
                  tooltip: 'Tambah 1',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
