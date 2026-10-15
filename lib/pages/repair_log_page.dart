import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../theme.dart';
import '../models/repair_log.dart';
import '../services/hive_database_service.dart';
import '../widgets/common.dart';

class RepairLogPage extends StatelessWidget {
  const RepairLogPage({super.key});

  void _showAddLogForm(BuildContext context) {
    final targetCtrl = TextEditingController();
    final issueCtrl = TextEditingController();
    final actionCtrl = TextEditingController();
    final techCtrl = TextEditingController();

    // Ambil daftar nomor PC yang ada untuk saran cepat
    final existingPCs = HiveDatabaseService.instance.getAllPCs();

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
                  const Icon(Icons.build_circle_rounded, color: lil, size: 22),
                  const SizedBox(width: 10),
                  tx('Catat Riwayat Perbaikan Baru', 18, w: FontWeight.w700),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetCtrl,
                decoration: dec('Target PC / Alat (contoh: PC-04)', prefix: const Icon(Icons.computer_rounded, color: Colors.white54, size: 18)),
              ),
              if (existingPCs.isNotEmpty) ...[
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final pc in existingPCs)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: tx(pc.pcNumber, 11, c: lil, w: FontWeight.w600),
                            backgroundColor: a(lil, 0.1),
                            side: BorderSide(color: a(lil, 0.2)),
                            padding: EdgeInsets.zero,
                            onPressed: () => setSheetState(() => targetCtrl.text = pc.pcNumber),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: issueCtrl,
                decoration: dec('Jenis Kerusakan / Gejala Masalah', prefix: const Icon(Icons.report_problem_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: actionCtrl,
                decoration: dec('Tindakan Perbaikan / Solusi Teknis', prefix: const Icon(Icons.handyman_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: techCtrl,
                decoration: dec('Nama Teknisi Penanggung Jawab', prefix: const Icon(Icons.person_rounded, color: Colors.white54, size: 18)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: btn('Simpan', () {
                  final target = targetCtrl.text.trim();
                  final issue = issueCtrl.text.trim();
                  final action = actionCtrl.text.trim();
                  final tech = techCtrl.text.trim();

                  if (target.isEmpty || issue.isEmpty || action.isEmpty) {
                    snack(context, 'Lengkapi data target, kerusakan, dan tindakan terlebih dahulu', isError: true);
                    return;
                  }

                  final newLog = RepairLog(
                    id: 'log_${DateTime.now().millisecondsSinceEpoch}',
                    target: target,
                    issue: issue,
                    action: action,
                    technician: tech.isEmpty ? 'Teknisi Lab' : tech,
                    createdAt: DateTime.now(),
                  );

                  HiveDatabaseService.instance.saveRepairLog(newLog);
                  Navigator.pop(ctx);
                  snack(context, 'Log perbaikan $target berhasil disimpan ke log_box!');
                }, icon: Icons.save_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, RepairLog item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: tx('Hapus Log Perbaikan?', 18, w: FontWeight.w700),
        content: tx(
          'Catatan perbaikan ${item.target} pada ${fdt(item.createdAt)} akan dihapus dari log_box.',
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
              HiveDatabaseService.instance.deleteRepairLog(item.id);
              Navigator.pop(ctx);
              snack(context, 'Log perbaikan dihapus');
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
      valueListenable: db.logBox.listenable(),
      builder: (context, Box box, _) {
        final logs = db.getAllRepairLogs();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          physics: const BouncingScrollPhysics(),
          children: [
            tx('Log Riwayat Perbaikan', 22, w: FontWeight.w700, al: TextAlign.center),
            const SizedBox(height: 16),

            // Overview card
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
                      color: a(lil, 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.assignment_turned_in_rounded, color: lil, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx('Total Tindakan Servis', 11, c: Colors.white54),
                        const SizedBox(height: 2),
                        tx('${logs.length} Log Tersimpan Permanen', 15, w: FontWeight.w700, c: Colors.white),
                      ],
                    ),
                  ),
                  btn('Catat', () => _showAddLogForm(context), tonal: true, icon: Icons.add_rounded),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                tx('Riwayat Tindakan Terbaru', 15, w: FontWeight.w600),
              ],
            ),
            const SizedBox(height: 8),

            for (final item in logs) _buildLogCard(context, item),

            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.history_edu_rounded, size: 40, color: Colors.white24),
                    const SizedBox(height: 10),
                    tx('Belum ada log perbaikan yang dicatat', 13, c: Colors.white38, al: TextAlign.center),
                    const SizedBox(height: 12),
                    btn('+ Catat Perbaikan Pertama', () => _showAddLogForm(context), tonal: true),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLogCard(BuildContext context, RepairLog item) {
    return Box(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: a(lil, 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: a(lil, 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.build_rounded, size: 12, color: lil),
                    const SizedBox(width: 5),
                    tx(item.target, 12, c: lil, w: FontWeight.w700),
                  ],
                ),
              ),
              const Spacer(),
              tx(fdt(item.createdAt), 11, c: Colors.white38),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.white38),
                onPressed: () => _confirmDeleteLog(context, item),
                tooltip: 'Hapus log',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Problem info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.report_problem_rounded, size: 15, color: org),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tx('Gejala / Kerusakan:', 11, c: Colors.white54),
                    tx(item.issue, 13, w: FontWeight.w600, c: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Action info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: mint),
                    const SizedBox(width: 6),
                    tx('Tindakan Solusi:', 11, c: mint, w: FontWeight.w600),
                  ],
                ),
                const SizedBox(height: 4),
                tx(item.action, 12, c: Colors.white90),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: Colors.white45),
                    const SizedBox(width: 5),
                    tx('Teknisi: ${item.technician}', 11, c: Colors.white60, w: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
