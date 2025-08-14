import '../database/database_helper.dart';
import '../models/loan.dart';
import 'package:uuid/uuid.dart';

class LoanService {
  static final LoanService instance = LoanService._init();
  LoanService._init();

  final _uuid = const Uuid();

  Future<List<Loan>> getAllLoans() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'loans',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<List<Loan>> getLoansByType(String type) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'loans',
      where: 'isActive = ? AND type = ?',
      whereArgs: [1, type],
      orderBy: 'endDate ASC',
    );
    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<Loan?> getLoanById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Loan.fromMap(maps.first);
    }
    return null;
  }

  Future<String> createLoan(Loan loan) async {
    final db = await DatabaseHelper.instance.database;
    final id = _uuid.v4();
    final loanWithId = Loan(
      id: id,
      title: loan.title,
      amount: loan.amount,
      type: loan.type,
      interestRate: loan.interestRate,
      startDate: loan.startDate,
      endDate: loan.endDate,
      monthlyPayment: loan.monthlyPayment,
      remainingAmount: loan.remainingAmount,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert('loans', loanWithId.toMap());
    return id;
  }

  Future<void> updateLoan(Loan loan) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  Future<void> deleteLoan(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'loans',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> makePayment(String loanId, double paymentAmount) async {
    final loan = await getLoanById(loanId);
    if (loan != null) {
      final newRemainingAmount =
          (loan.remainingAmount - paymentAmount).clamp(0.0, loan.amount);
      await updateLoan(loan.copyWith(remainingAmount: newRemainingAmount));
    }
  }

  Future<Map<String, double>> getLoanStats() async {
    final loans = await getAllLoans();

    double totalLent = 0;
    double totalBorrowed = 0;
    double totalRemainingLent = 0;
    double totalRemainingBorrowed = 0;
    int overdueLoans = 0;
    int dueSoonLoans = 0;

    for (final loan in loans) {
      if (loan.type == 'given') {
        totalLent += loan.amount;
        totalRemainingLent += loan.remainingAmount;
      } else {
        totalBorrowed += loan.amount;
        totalRemainingBorrowed += loan.remainingAmount;
      }

      if (loan.isOverdue) overdueLoans++;
      if (loan.isDueSoon) dueSoonLoans++;
    }

    return {
      'totalLent': totalLent,
      'totalBorrowed': totalBorrowed,
      'totalRemainingLent': totalRemainingLent,
      'totalRemainingBorrowed': totalRemainingBorrowed,
      'netLoanPosition': totalRemainingLent - totalRemainingBorrowed,
      'overdueLoans': overdueLoans.toDouble(),
      'dueSoonLoans': dueSoonLoans.toDouble(),
      'totalLoans': loans.length.toDouble(),
    };
  }

  Future<List<Loan>> getOverdueLoans() async {
    final loans = await getAllLoans();
    return loans.where((loan) => loan.isOverdue).toList();
  }

  Future<List<Loan>> getLoansDueSoon() async {
    final loans = await getAllLoans();
    return loans.where((loan) => loan.isDueSoon).toList();
  }
}
