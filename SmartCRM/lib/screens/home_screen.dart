import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../core/models/home_stats.dart';
import '../core/services/auth_service.dart';
import '../core/services/dashboard_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/smart_app_bar.dart';
import 'funil_screen.dart';
import 'leads_screen.dart';
import 'login_screen.dart';
import 'oportunidades_screen.dart';
import 'relatorios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  HomeStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await _dashboardService.loadHomeStats();
      if (mounted) setState(() => _stats = stats);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () {
              AuthService().logout();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.logout),
          ),
        ),
      ),
    );
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _load();
  }

  Widget _navButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartHomeAppBar(onLogout: _logout),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          MetricCard(
                            label: 'Leads totais',
                            value: '${_stats!.leadsTotais}'.padLeft(2, '0'),
                            color: AppColors.purple,
                          ),
                          MetricCard(
                            label: 'Oportunidades em aberto',
                            value:
                                '${_stats!.oportunidadesAbertas}'.padLeft(2, '0'),
                            color: AppColors.lightBlue,
                          ),
                          MetricCard(
                            label: 'Oportunidades perdidas',
                            value:
                                '${_stats!.oportunidadesPerdidas}'.padLeft(2, '0'),
                            color: AppColors.pink,
                          ),
                          MetricCard(
                            label: 'Vendas concluídas',
                            value:
                                '${_stats!.vendasConcluidas}'.padLeft(2, '0'),
                            color: AppColors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _navButton('LEADS', () => _openScreen(const LeadsScreen())),
                      _navButton(
                        'OPORTUNIDADES',
                        () => _openScreen(const OportunidadesScreen()),
                      ),
                      _navButton('FUNIL', () => _openScreen(const FunilScreen())),
                      _navButton(
                        'RELATÓRIOS',
                        () => _openScreen(const RelatoriosScreen()),
                      ),
                    ],
                  ),
                ),
    );
  }
}
