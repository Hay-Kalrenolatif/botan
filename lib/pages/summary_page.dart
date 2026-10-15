import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../theme.dart';
import '../models/pc_item.dart';
import '../models/support_item.dart';
import '../models/repair_log.dart';
import '../services/hive_database_service.dart';
import '../widgets/common.dart';
import '../widgets/ring.dart';

class SummaryPage extends StatelessWidget {
  final void Function(int) navigateTo;
  const SummaryPage({super.key, required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    final db = HiveDatabaseService.instance;

    return ValueListenableBuilder(
      valueListenable: db.pcBox.listenable(),
      builder: (context, Box pcBox, _) {
        return ValueListenableBuilder(
          valueListenable: db.supportBox.listenable(),
          builder: (context, Box supportBox, _) {
            return ValueListenableBuilder(
              valueListenable: db.logBox.listenable(),
              builder: (context, Box logBox, _) {
                final pcs = db.getAllPCs();
                final supports = db.getAllSupportItems();
                final logs = db.getAllRepairLogs();

                final totalPC = pcs.length;
                final normalPC = pcs.where((p) => p.isNormal).length;
                final brokenPC = totalPC - normalPC;
                final pcReadyPct = totalPC == 0 ? 1.0 : cl(normalPC / totalPC);

                final totalSupportQty = supports.fold<int>(0, (s, item) => s + item.qty);
                final goodSupportQty = supports
                    .where((item) => item.isGood)
                    .fold<int>(0, (s, item) => s + item.qty);
                final supportReadyPct = totalSupportQty == 0 ? 1.0 : cl(goodSupportQty / totalSupportQty);

                final brokenSupportCount = supports.where((item) => item.isBroken || item.condition == 'Perlu Cek').length;
                final hasIssues = brokenPC > 0 || brokenSupportCount > 0;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Header Bar
                    Row(
                      children: [
                        const Logo(),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: a(mint, 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PulseBadge(color: hasIssues ? org : mint),
                              const SizedBox(width: 6),
                              tx(hasIssues ? '$brokenPC PC Butuh Servis' : 'Lab Siap Pakai', 11, c: hasIssues ? org : mint, w: FontWeight.w600),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Greeting
                    tx('Lab', 14, c: Colors.white54, al: TextAlign.center),
                    const SizedBox(height: 4),
                    tx('Kesiapan Fasilitas & Inventaris', 24, w: FontWeight.w700, al: TextAlign.center),
                    const SizedBox(height: 18),

                    // Concentric Rings Status
                    Box(
                      Column(
                        children: [
                          Ring(
                            [pcReadyPct, supportReadyPct, 1.0],
                            [mint, yel, lil],
                            size: 195,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                tx('${(pcReadyPct * 100).round()}%', 32, w: FontWeight.w800),
                                tx('Kesiapan PC', 11, c: Colors.white54),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                              color: cardSurface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _SummaryMetricItem(
                                  value: '$normalPC / $totalPC',
                                  label: 'PC Normal',
                                  color: mint,
                                ),
                                _SummaryMetricItem(
                                  value: '${(supportReadyPct * 100).round()}%',
                                  label: 'Alat Pendukung',
                                  color: yel,
                                ),
                                _SummaryMetricItem(
                                  value: '${logs.length}',
                                  label: 'Riwayat Servis',
                                  color: lil,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Peringatan Cepat (jika ada unit rusak)
                    if (hasIssues)
                      Box(
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: a(org, 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: org, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tx('Perlu Penanganan Teknis', 13, w: FontWeight.w700, c: org),
                                  const SizedBox(height: 2),
                                  tx(
                                    '$brokenPC unit PC rusak dan $brokenSupportCount inventaris non-PC membutuhkan perbaikan/pengecekan.',
                                    11,
                                    c: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        borderColor: a(org, 0.3),
                        onTap: () => navigateTo(1),
                      ),

                    tx('Akses Cepat', 14, w: FontWeight.w600),
                    const SizedBox(height: 10),

                    // Card 1: PC Management
                    Box(
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: a(mint, 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: a(mint, 0.25)),
                            ),
                            child: const Icon(Icons.desktop_windows_rounded, color: mint, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    tx('Manajemen Unit PC', 15, w: FontWeight.w700),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: a(mint, 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: tx('$totalPC unit', 11, c: mint, w: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                tx(
                                  'Nomor PC, Prosesor, RAM & Status Operasional ($normalPC Normal, $brokenPC Rusak)',
                                  11,
                                  c: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                        ],
                      ),
                      onTap: () => navigateTo(1),
                    ),

                    // Card 2: Support Inventory
                    Box(
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: a(yel, 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: a(yel, 0.25)),
                            ),
                            child: const Icon(Icons.devices_other_rounded, color: yel, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    tx('Inventaris Pendukung Lab', 15, w: FontWeight.w700),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: a(yel, 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: tx('${supports.length} item', 11, c: yel, w: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                tx(
                                  'Switch Hub, Proyektor, UPS, Kabel Jaringan ($totalSupportQty total unit)',
                                  11,
                                  c: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                        ],
                      ),
                      onTap: () => navigateTo(2),
                    ),

                    // Card 3: Repair Log
                    Box(
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: a(lil, 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: a(lil, 0.25)),
                            ),
                            child: const Icon(Icons.build_circle_rounded, color: lil, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    tx('Log Riwayat Perbaikan', 15, w: FontWeight.w700),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: a(lil, 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: tx('${logs.length} catatan', 11, c: lil, w: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                tx(
                                  logs.isNotEmpty
                                      ? 'Servis terakhir: ${logs.first.target} oleh ${logs.first.technician}'
                                      : 'Belum ada riwayat perbaikan yang tercatat',
                                  11,
                                  c: Colors.white54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                        ],
                      ),
                      onTap: () => navigateTo(3),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SummaryMetricItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryMetricItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          tx(value, 16, w: FontWeight.w700),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 5),
              tx(label, 11, c: Colors.white60),
            ],
          ),
        ],
      );
}
