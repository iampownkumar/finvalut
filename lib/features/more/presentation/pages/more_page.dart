import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finvault/core/providers/theme_provider.dart';
import 'package:finvault/features/export/presentation/pages/export_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Analytics'),
                  subtitle: const Text('View financial insights and trends'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/analytics'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Export & Backup'),
                  subtitle: const Text('Export data and create backups'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: const Text('All Transactions'),
                  subtitle: const Text('View and manage all transactions'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/transactions'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Categories'),
                  subtitle: const Text('Manage income and expense categories'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/categories'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  subtitle: const Text('Theme, currency and preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'FinVault',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          '© 2024 FinVault. All rights reserved.',
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'FinVault is a comprehensive personal finance manager '
                          'that helps you track expenses, manage accounts, '
                          'monitor credit cards, and handle loans efficiently.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
