import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../theme.dart';
import '../models/pc_item.dart';
import '../services/hive_database_service.dart';
import '../widgets/common.dart';

class PCManagementPage extends StatefulWidget {
  const PCManagementPage({super.key});

  @override
  State<PCManagementPage> createState() => _PCManagementPageState();
}

class _PCManagementPageState extends State<PCManagementPage> {
  int filterIndex = 0; // 0 = Semua, 1 = Normal, 2 = Rusak

  void _showPCForm(BuildContext context, [PCItem? existing]) {
    final isEdit = existing != null;
    final numCtrl = TextEditingController(text: existing?.pcNumber ?? '');
    final procCtrl = TextEditingController(text: existing?.processor ?? 'Intel Core i5-12400');
    final ramCtrl = TextEditingController(text: existing?.ram ?? '16 GB DDR4');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String status = existing?.status ?? 'Normal';

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
                  const Icon(Icons.desktop_windows_rounded, color: mint, size: 22),
                  const SizedBox(width: 10),
                  tx(isEdit ? 'Edit Spesifikasi PC' : 'Tambah Unit PC Baru', 18, w: FontWeight.w700),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numCtrl,
                decoration: dec('Nomor / Label PC (contoh: PC-01)', prefix: const Icon(Icons.tag_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: procCtrl,
                decoration: dec('Tipe Prosesor', prefix: const Icon(Icons.memory_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final p in ['Core i5-12400', 'Core i7-13700', 'Ryzen 5 5600G', 'Core i3-12100'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: tx(p, 11, c: mint, w: FontWeight.w600),
                          backgroundColor: a(mint, 0.1),
                          side: BorderSide(color: a(mint, 0.2)),
                          padding: EdgeInsets.zero,
                          onPressed: () => setSheetState(() => procCtrl.text = p),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ramCtrl,
                decoration: dec('Kapasitas RAM', prefix: const Icon(Icons.storage_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final r in ['8 GB DDR4', '16 GB DDR4', '32 GB DDR4', '16 GB DDR5'])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: tx(r, 11, c: yel, w: FontWeight.w600),
                        backgroundColor: a(yel, 0.1),
                        side: BorderSide(color: a(yel, 0.2)),
                        padding: EdgeInsets.zero,
                        onPressed: () => setSheetState(() => ramCtrl.text = r),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              // Status selector
              tx('Status Operasional Unit', 12, c: Colors.white60),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => status = 'Normal'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: status == 'Normal' ? a(mint, 0.15) : cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: status == 'Normal' ? mint : Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 16, color: status == 'Normal' ? mint : Colors.white38),
                            const SizedBox(width: 6),
                            tx('Normal', 13, c: status == 'Normal' ? mint : Colors.white70, w: FontWeight.w600),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => status = 'Rusak'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: status == 'Rusak' ? a(org, 0.15) : cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: status == 'Rusak' ? org : Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 16, color: status == 'Rusak' ? org : Colors.white38),
                            const SizedBox(width: 6),
                            tx('Rusak', 13, c: status == 'Rusak' ? org : Colors.white70, w: FontWeight.w600),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: dec('Catatan Tambahan (Opsional)', prefix: const Icon(Icons.edit_note_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: btn(isEdit ? 'Perbarui Data PC' : 'Simpan', () {
                  final num = numCtrl.text.trim();
                  final proc = procCtrl.text.trim();
                  final ram = ramCtrl.text.trim();

                  if (num.isEmpty) {
                    snack(context, 'Masukkan nomor/label PC terlebih dahulu', isError: true);
                    return;
                  }

                  final item = PCItem(
                    id: existing?.id ?? 'pc_${DateTime.now().millisecondsSinceEpoch}',
                    pcNumber: num,
                    processor: proc.isEmpty ? 'Intel Core i5' : proc,
                    ram: ram.isEmpty ? '16 GB' : ram,
                    status: status,
                    updatedAt: DateTime.now(),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );

                  HiveDatabaseService.instance.savePC(item);
                  Navigator.pop(ctx);
                  snack(context, '$num berhasil disimpan ke pc_box!');
                }, icon: Icons.save_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePC(BuildContext context, PCItem pc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: tx('Hapus Data PC?', 18, w: FontWeight.w700),
        content: tx(
          'Unit "${pc.pcNumber}" (${pc.processor}, ${pc.ram}) akan dihapus secara permanen!!!.',
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
              HiveDatabaseService.instance.deletePC(pc.id);
              Navigator.pop(ctx);
              snack(context, '${pc.pcNumber} telah dihapus');
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
      valueListenable: db.pcBox.listenable(),
      builder: (context, Box box, _) {
        final allPcs = db.getAllPCs();
        final filtered = allPcs.where((p) {
          if (filterIndex == 1) return p.isNormal;
          if (filterIndex == 2) return !p.isNormal;
          return true;
        }).toList();

        final normalCount = allPcs.where((p) => p.isNormal).length;
        final brokenCount = allPcs.length - normalCount;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            tx('Manajemen PC & Spesifikasi', 22, w: FontWeight.w700, al: TextAlign.center),

            // Segmented Filter
            Seg(
              const ['Semua', 'Normal', 'Rusak'],
              filterIndex,
              (val) => setState(() => filterIndex = val),
            ),

            // Quick Counter Banner
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tx('PC Normal', 11, c: Colors.white54),
                            const SizedBox(height: 2),
                            tx('$normalCount Unit', 18, w: FontWeight.w700, c: mint),
                          ],
                        ),
                        const Icon(Icons.check_circle_rounded, color: mint, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tx('PC Rusak', 11, c: Colors.white54),
                            const SizedBox(height: 2),
                            tx('$brokenCount Unit', 18, w: FontWeight.w700, c: brokenCount > 0 ? org : Colors.white70),
                          ],
                        ),
                        Icon(Icons.warning_amber_rounded, color: brokenCount > 0 ? org : Colors.white38, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Header Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tx('Daftar Unit PC (${filtered.length})', 15, w: FontWeight.w600),
                TextButton.icon(
                  onPressed: () => _showPCForm(context),
                  icon: const Icon(Icons.add_rounded, size: 16, color: mint),
                  label: tx('PC Baru', 13, c: mint, w: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // PC Cards List
            for (final pc in filtered) _buildPCCard(context, pc),

            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.desktop_access_disabled_rounded, size: 40, color: Colors.white24),
                    const SizedBox(height: 10),
                    tx('Tidak ada unit PC pada filter ini', 13, c: Colors.white38, al: TextAlign.center),
                    const SizedBox(height: 12),
                    btn('+ Tambah Unit PC', () => _showPCForm(context), tonal: true),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPCCard(BuildContext context, PCItem pc) {
    final isNormal = pc.isNormal;
    final color = isNormal ? mint : org;

    return Panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: a(color, 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: a(color, 0.3)),
                ),
                child: Icon(Icons.desktop_windows_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        tx(pc.pcNumber, 16, w: FontWeight.w700),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: a(color, 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: a(color, 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PulseBadge(color: color),
                              const SizedBox(width: 5),
                              tx(pc.status, 11, c: color, w: FontWeight.w700),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    tx('Pembaruan: ${fd(pc.updatedAt)}', 11, c: Colors.white38),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white54),
                onPressed: () => _showPCForm(context, pc),
                tooltip: 'Edit spesifikasi',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white38),
                onPressed: () => _confirmDeletePC(context, pc),
                tooltip: 'Hapus PC',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Specs detail chip box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.memory_rounded, size: 14, color: Colors.white54),
                    const SizedBox(width: 6),
                    Expanded(child: tx('Prosesor', 12, c: Colors.white54)),
                    tx(pc.processor, 12, w: FontWeight.w600, c: Colors.white),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.storage_rounded, size: 14, color: Colors.white54),
                    const SizedBox(width: 6),
                    Expanded(child: tx('RAM', 12, c: Colors.white54)),
                    tx(pc.ram, 12, w: FontWeight.w600, c: yel),
                  ],
                ),
                if (pc.notes != null && pc.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sticky_note_2_outlined, size: 14, color: Colors.white54),
                      const SizedBox(width: 6),
                      Expanded(child: tx('Catatan', 12, c: Colors.white54)),
                      Expanded(
                        flex: 2,
                        child: tx(pc.notes!, 12, c: Colors.white70, al: TextAlign.right),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action button to switch status
          SizedBox(
            width: double.infinity,
            child: btn(
              isNormal ? 'Tandai Sebagai Rusak' : 'Tandai Normal (Siap Pakai)',
              () {
                HiveDatabaseService.instance.togglePCStatus(pc.id);
                snack(
                  context,
                  isNormal
                      ? '${pc.pcNumber} ditandai sebagai Rusak'
                      : '${pc.pcNumber} ditandai kembali Normal!',
                  isError: isNormal,
                );
              },
              tonal: true,
              icon: isNormal ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
