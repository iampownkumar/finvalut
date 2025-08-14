import 'package:flutter/material.dart';
import 'package:finvault/features/export/services/export_service.dart';
import 'package:finvault/features/export/presentation/widgets/export_option_card.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Backup'),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Data',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Export your financial data in various formats',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Export Options
                  ExportOptionCard(
                    title: 'Financial Report (PDF)',
                    subtitle:
                        'Complete financial overview with charts and summaries',
                    icon: Icons.picture_as_pdf,
                    color: Colors.red,
                    onTap: () => _exportPDFReport(),
                  ),
                  const SizedBox(height: 16),

                  ExportOptionCard(
                    title: 'Transactions (CSV)',
                    subtitle: 'Export all transactions in spreadsheet format',
                    icon: Icons.table_chart,
                    color: Colors.green,
                    onTap: () => _showDateRangeSelector(),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Backup & Restore',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Backup your data or restore from previous backup',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 24),

                  ExportOptionCard(
                    title: 'Create Backup',
                    subtitle: 'Save all your data to a backup file',
                    icon: Icons.backup,
                    color: Colors.blue,
                    onTap: () => _createBackup(),
                  ),
                  const SizedBox(height: 16),

                  ExportOptionCard(
                    title: 'Restore from Backup',
                    subtitle: 'Import data from a backup file',
                    icon: Icons.restore,
                    color: Colors.orange,
                    onTap: () => _showRestoreDialog(),
                  ),
                  const SizedBox(height: 32),

                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Export Tips',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• PDF reports include charts and summaries\n'
                            '• CSV exports can be opened in Excel/Sheets\n'
                            '• Regular backups help protect your data\n'
                            '• All exports are saved to your device',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _exportPDFReport() async {
    setState(() => isLoading = true);
    try {
      final filePath =
          await ExportService.instance.exportFinancialReportToPDF();

      if (mounted) {
        setState(() => isLoading = false);
        _showExportSuccessDialog('PDF Report', filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorDialog('Failed to export PDF report: $e');
      }
    }
  }

  Future<void> _exportTransactionsCSV(
      {DateTime? startDate, DateTime? endDate}) async {
    setState(() => isLoading = true);
    try {
      final filePath = await ExportService.instance.exportTransactionsToCSV(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() => isLoading = false);
        _showExportSuccessDialog('Transactions CSV', filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorDialog('Failed to export transactions: $e');
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => isLoading = true);
    try {
      final filePath = await ExportService.instance.createBackup();

      if (mounted) {
        setState(() => isLoading = false);
        _showExportSuccessDialog('Backup', filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorDialog('Failed to create backup: $e');
      }
    }
  }

  void _showDateRangeSelector() {
    showDialog(
      context: context,
      builder: (context) => _DateRangeSelector(
        onExport: _exportTransactionsCSV,
      ),
    );
  }

  void _showExportSuccessDialog(String type, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$type has been exported successfully!'),
            const SizedBox(height: 16),
            Text(
              'File Location:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              filePath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ExportService.instance.shareFile(filePath, type);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Backup'),
        content: const Text(
          'Restore functionality will be available in a future update. '
          'For now, you can create backups to preserve your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends StatefulWidget {
  final Function({DateTime? startDate, DateTime? endDate}) onExport;

  const _DateRangeSelector({required this.onExport});

  @override
  State<_DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<_DateRangeSelector> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Transactions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select date range for transaction export:'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectStartDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                        : 'Start Date',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectEndDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'End Date',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Leave dates empty to export all transactions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onExport(startDate: startDate, endDate: endDate);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => endDate = date);
    }
  }
}
