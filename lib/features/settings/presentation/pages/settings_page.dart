import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finvault/core/providers/theme_provider.dart';
import 'package:finvault/core/providers/currency_provider.dart';
import 'package:finvault/core/utils/currency_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('Use System Theme'),
                  trailing: Radio<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (mode) =>
                        themeProvider.setThemeMode(ThemeMode.system),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency'),
                  subtitle: Text(
                      'Current: ${currencyProvider.currencyCode} (${CurrencyUtils.symbolFor(currencyProvider.currencyCode)})'),
                ),
                const Divider(height: 1),
                _CurrencyOption(code: 'INR', label: 'Indian Rupee (₹)'),
                const Divider(height: 1),
                // _CurrencyOption(code: 'USD', label: "US Dollar ($)"),
                const Divider(height: 1),
                _CurrencyOption(code: 'EUR', label: 'Euro (€)'),
                const Divider(height: 1),
                _CurrencyOption(code: 'GBP', label: 'British Pound (£)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String code;
  final String label;

  const _CurrencyOption({required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final selected = currencyProvider.currencyCode == code;

    return ListTile(
      leading: const Icon(Icons.payments),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        currencyProvider.setCurrency(code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Currency set to $label')),
        );
      },
    );
  }
}
