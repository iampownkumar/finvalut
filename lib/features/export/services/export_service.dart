import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:finvault/core/models/transaction.dart';
import 'package:finvault/core/models/account.dart';
import 'package:finvault/core/models/credit_card.dart';
import 'package:finvault/core/models/loan.dart';
import 'package:finvault/core/services/transaction_service.dart';
import 'package:finvault/core/services/account_service.dart';
import 'package:finvault/core/services/credit_card_service.dart';
import 'package:finvault/core/services/loan_service.dart';
import 'package:finvault/core/services/analytics_service.dart';
import 'package:finvault/core/utils/currency_utils.dart';
import 'package:finvault/core/utils/date_utils.dart';

class ExportService {
  static final ExportService instance = ExportService._init();
  ExportService._init();

  // Export transactions to CSV
  Future<String> exportTransactionsToCSV(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final transactions =
          await TransactionService.instance.getAllTransactions();

      // Filter by date if provided
      final filteredTransactions = transactions.where((transaction) {
        if (startDate != null && transaction.date.isBefore(startDate))
          return false;
        if (endDate != null && transaction.date.isAfter(endDate)) return false;
        return true;
      }).toList();

      final headers = [
        'Date',
        'Description',
        'Category',
        'Account',
        'Type',
        'Amount',
        'Created At'
      ];

      final rows = filteredTransactions
          .map((transaction) => [
                AppDateUtils.formatDate(transaction.date),
                transaction.description ?? '',
                transaction.categoryName ?? '',
                transaction.accountName ?? '',
                transaction.type,
                transaction.amount.toString(),
                AppDateUtils.formatDate(transaction.createdAt),
              ])
          .toList();

      final csvData = [headers, ...rows];
      final csvString = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'finvault_transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export transactions: $e');
    }
  }

  // Export financial report to PDF
  Future<String> exportFinancialReportToPDF() async {
    try {
      final pdf = pw.Document();

      // Get data
      final [transactions, accounts, creditCards, loans, analytics] =
          await Future.wait([
        TransactionService.instance.getAllTransactions(limit: 100),
        AccountService.instance.getAllAccounts(),
        CreditCardService.instance.getAllCreditCards(),
        LoanService.instance.getAllLoans(),
        AnalyticsService.instance.getFinancialSummary(),
      ]);

      final transactionList = transactions as List<Transaction>;
      final accountsList = accounts as List<Account>;
      final cardsList = creditCards as List<CreditCard>;
      final loansList = loans as List<Loan>;
      final analyticsData = analytics as Map<String, dynamic>;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'FinVault Financial Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Report Date
              pw.Text(
                'Generated on: ${AppDateUtils.formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Financial Summary
              _buildPdfSection('Financial Summary', [
                _buildPdfKeyValue(
                    'This Month Income',
                    CurrencyUtils.formatAmount(
                        analyticsData['thisMonth']['income'] ?? 0)),
                _buildPdfKeyValue(
                    'This Month Expense',
                    CurrencyUtils.formatAmount(
                        analyticsData['thisMonth']['expense'] ?? 0)),
                _buildPdfKeyValue(
                    'Net Income',
                    CurrencyUtils.formatAmount(
                        analyticsData['thisMonth']['net'] ?? 0)),
                _buildPdfKeyValue(
                    'Total Accounts', accountsList.length.toString()),
              ]),

              // Accounts Summary
              if (accountsList.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _buildPdfSection('Accounts Summary', [
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          _buildPdfTableCell('Account Name', isHeader: true),
                          _buildPdfTableCell('Type', isHeader: true),
                          _buildPdfTableCell('Balance', isHeader: true),
                        ],
                      ),
                      ...accountsList.map((account) => pw.TableRow(
                            children: [
                              _buildPdfTableCell(account.name),
                              _buildPdfTableCell(account.type),
                              _buildPdfTableCell(
                                  CurrencyUtils.formatAmount(account.balance)),
                            ],
                          )),
                    ],
                  ),
                ]),
              ],

              // Credit Cards Summary
              if (cardsList.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _buildPdfSection('Credit Cards Summary', [
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          _buildPdfTableCell('Bank', isHeader: true),
                          _buildPdfTableCell('Limit', isHeader: true),
                          _buildPdfTableCell('Used', isHeader: true),
                          _buildPdfTableCell('Utilization', isHeader: true),
                        ],
                      ),
                      ...cardsList.map((card) => pw.TableRow(
                            children: [
                              _buildPdfTableCell(card.bankName),
                              _buildPdfTableCell(
                                  CurrencyUtils.formatAmount(card.cardLimit)),
                              _buildPdfTableCell(
                                  CurrencyUtils.formatAmount(card.usedAmount)),
                              _buildPdfTableCell(
                                  '${card.utilizationPercentage.toStringAsFixed(1)}%'),
                            ],
                          )),
                    ],
                  ),
                ]),
              ],

              // Recent Transactions
              if (transactionList.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                _buildPdfSection('Recent Transactions', [
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.5),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          _buildPdfTableCell('Date', isHeader: true),
                          _buildPdfTableCell('Description', isHeader: true),
                          _buildPdfTableCell('Category', isHeader: true),
                          _buildPdfTableCell('Type', isHeader: true),
                          _buildPdfTableCell('Amount', isHeader: true),
                        ],
                      ),
                      ...transactionList.take(20).map((transaction) =>
                          pw.TableRow(
                            children: [
                              _buildPdfTableCell(AppDateUtils.formatShortDate(
                                  transaction.date)),
                              _buildPdfTableCell(transaction.description ?? ''),
                              _buildPdfTableCell(
                                  transaction.categoryName ?? ''),
                              _buildPdfTableCell(transaction.type),
                              _buildPdfTableCell(
                                  '${transaction.type == 'expense' ? '-' : '+'}${CurrencyUtils.formatAmount(transaction.amount)}'),
                            ],
                          )),
                    ],
                  ),
                ]),
              ],

              // Footer
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.Text(
                'Generated by FinVault - Personal Finance Manager',
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
            ];
          },
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'finvault_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception('Failed to generate PDF report: $e');
    }
  }

  pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...children,
      ],
    );
  }

  pw.Widget _buildPdfKeyValue(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(key, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // Backup all data to JSON
  Future<String> createBackup() async {
    try {
      final [transactions, accounts, creditCards, loans] = await Future.wait([
        TransactionService.instance.getAllTransactions(),
        AccountService.instance.getAllAccounts(),
        CreditCardService.instance.getAllCreditCards(),
        LoanService.instance.getAllLoans(),
      ]);

      final backupData = {
        'version': '1.0',
        'createdAt': DateTime.now().toIso8601String(),
        'data': {
          'transactions': (transactions as List<Transaction>)
              .map((t) => t.toMap())
              .toList(),
          'accounts':
              (accounts as List<Account>).map((a) => a.toMap()).toList(),
          'creditCards':
              (creditCards as List<CreditCard>).map((c) => c.toMap()).toList(),
          'loans': (loans as List<Loan>).map((l) => l.toMap()).toList(),
        },
      };

      // Save backup file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'finvault_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(backupData.toString());

      return file.path;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Share file
  Future<void> shareFile(String filePath, String title) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: title,
        text: 'FinVault Export - $title',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  // Print PDF
  Future<void> printPDF(String filePath) async {
    try {
      final file = File(filePath);
      final pdfData = await file.readAsBytes();
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfData);
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }
}
