import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class KFBotItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const KFBotItem(this.label, this.icon, this.activeIcon);
}

class KelasFunBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const KelasFunBottomBar({super.key, required this.currentIndex, required this.onTap});

  static const items = [
    KFBotItem('Beranda', Icons.dashboard_outlined, Icons.dashboard),
    KFBotItem('Presensi', Icons.qr_code_scanner_outlined, Icons.qr_code_scanner),
    KFBotItem('Siswa', Icons.people_outline, Icons.people),
    KFBotItem('Peringkat', Icons.emoji_events_outlined, Icons.emoji_events),
    KFBotItem('Jadwal', Icons.calendar_today_outlined, Icons.calendar_today),
    KFBotItem('Lainnya', Icons.more_horiz, Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.lightBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i==currentIndex;
              final it = items[i];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: ()=>onTap(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(active ? it.activeIcon : it.icon, size: 20, color: active ? Colors.white : AppTheme.lightTextSecondary),
                        const SizedBox(height: 2),
                        Text(it.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: active ? Colors.white : AppTheme.lightTextSecondary)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
