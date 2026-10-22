import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onCompleted;
  const OnboardingPage({super.key, required this.onCompleted});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _Slide {
  final String svg;
  final String title;
  final String desc;
  const _Slide({required this.svg, required this.title, required this.desc});
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _page = PageController();
  int _index = 0;

  static const List<_Slide> _slides = [
    _Slide(
      svg: 'assets/images/Data extraction.svg',
      title: 'Selamat datang di LTrack',
      desc: 'Sistem manajemen inventaris laboratorium komputer: spesifikasi PC, barang pendukung, dan log perbaikan teknisi.',
    ),
    _Slide(
      svg: 'assets/images/Innovation.svg',
      title: 'Kelola PC dan Barang Pendukung',
      desc: 'Catat spesifikasi tiap PC dan stok barang pendukung dengan kondisinya.',
    ),
    _Slide(
      svg: 'assets/images/New Functions.svg',
      title: 'Catat Log Perbaikan Teknisi',
      desc: 'Catat riwayat perbaikan agar laboratorium selalu siap digunakan.',
    ),
  ];

  void _previous() => _page.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );

  void _next() {
    if (_index == _slides.length - 1) {
      widget.onCompleted();
    } else {
      _page.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Widget _buildSlide(_Slide s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(s.svg, width: 250, height: 250),
            const SizedBox(height: 32),
            tx(s.title, 22, c: Colors.white, w: FontWeight.w700),
            const SizedBox(height: 12),
            tx(s.desc, 15, c: Colors.white60, al: TextAlign.center, maxLines: 4),
          ],
        ),
      );

  // Dot indicator dengan animasi yang lebih halus
  Widget _dot(int index) {
    final isActive = index == _index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? mint : Colors.white24,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: mint.withAlpha(60),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirst = _index == 0;
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Dekorasi background (tetap statis)
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: yel.withAlpha(18),
                  border: Border.all(color: yel.withAlpha(30), width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mint.withAlpha(12),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _page,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: _slides.map((s) => _buildSlide(s)).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Indikator titik yang lebih halus
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, _dot),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _NavBar(
                      key: ValueKey('nav$isFirst'),
                      showBack: !isFirst,
                      nextLabel: isLast ? 'Mulai' : 'Selanjutnya',
                      onPrevious: _previous,
                      onNext: _next,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Bar navigasi bawah: "Sebelumnya" (teks + chevron) di kiri,
// pill aksi di kanan sesuai referensi desain
class _NavBar extends StatelessWidget {
  final bool showBack;
  final String nextLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  const _NavBar({
    super.key,
    required this.showBack,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: showBack
                ? TextButton.icon(
                    onPressed: onPrevious,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    label: const Text(
                      'Sebelumnya',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  )
                : null,
          ),
        ),
        _nextPill(nextLabel, onNext),
      ],
    );
  }

  Widget _nextPill(String label, VoidCallback onPressed) => FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        style: FilledButton.styleFrom(
          backgroundColor: yel,
          foregroundColor: bg,
          side: const BorderSide(color: mint, width: 2),
          minimumSize: const Size(164, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      );
}
