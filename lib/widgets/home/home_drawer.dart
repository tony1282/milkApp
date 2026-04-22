import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  final VoidCallback onFamilies;
  final VoidCallback onMilkCalendar;
  final VoidCallback onMilkFinances;
  final VoidCallback onCattleCalendar;
  final VoidCallback onCattleFinances;
  final VoidCallback onSettings;

  const HomeDrawer({
    super.key,
    required this.onFamilies,
    required this.onMilkCalendar,
    required this.onMilkFinances,
    required this.onCattleCalendar,
    required this.onCattleFinances,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              color: const Color(0xFF3D52A0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.agriculture_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Milk App',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const Text('Panel de control',
                      style:
                          TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            // ── Items ──────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.group_rounded,
                    label: 'Gestionar Familias',
                    onTap: onFamilies,
                  ),
                  const _DrawerSection(label: 'LECHE'),
                  _DrawerItem(
                    icon: Icons.water_drop_rounded,
                    label: 'Registrar Litros',
                    onTap: onMilkCalendar,
                  ),
                  _DrawerItem(
                    icon: Icons.payments_rounded,
                    label: 'Finanzas de Leche',
                    onTap: onMilkFinances,
                  ),
                  const _DrawerSection(label: 'ALIMENTO'),
                  _DrawerItem(
                    icon: Icons.grass_rounded,
                    label: 'Registrar Alimento',
                    onTap: onCattleCalendar,
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Gastos de Alimento',
                    onTap: onCattleFinances,
                  ),
                  const _DrawerSection(label: 'GENERAL'),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    label: 'Configuración',
                    onTap: onSettings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3D52A0), size: 18),
      ),
      title: Text(label,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String label;
  const _DrawerSection({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black38,
              letterSpacing: 1.5)),
    );
  }
}