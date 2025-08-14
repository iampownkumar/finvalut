import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:finvault/features/splash/presentation/pages/splash_page.dart';
import 'package:finvault/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:finvault/features/home/presentation/pages/home_page.dart';
import 'package:finvault/features/accounts/presentation/pages/accounts_page.dart';
import 'package:finvault/features/accounts/presentation/pages/account_details_page.dart';
import 'package:finvault/features/categories/presentation/pages/categories_page.dart';
import 'package:finvault/features/credit_cards/presentation/pages/credit_cards_page.dart';
import 'package:finvault/features/analytics/presentation/pages/analytics_page.dart';
import 'package:finvault/features/loans/presentation/pages/loans_page.dart';
import 'package:finvault/features/more/presentation/pages/more_page.dart';
import 'package:finvault/features/transactions/presentation/pages/add_edit_transaction_page.dart';
import 'package:finvault/features/transactions/presentation/pages/transactions_list_page.dart';
import 'package:finvault/shared/presentation/widgets/main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash', // Start with splash screen
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.toString()}" does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // Splash Screen (outside shell - full screen)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Welcome Screen (outside shell - full screen)
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),

      // Main app routes (inside shell with bottom navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/accounts',
            name: 'accounts',
            builder: (context, state) => const AccountsPage(),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesPage(),
          ),
          GoRoute(
            path: '/credit-cards',
            name: 'credit-cards',
            builder: (context, state) => const CreditCardsPage(),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/loans',
            name: 'loans',
            builder: (context, state) => const LoansPage(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsListPage(),
          ),
          GoRoute(
            path: '/more',
            name: 'more',
            builder: (context, state) => const MorePage(),
          ),
        ],
      ),

      // Full screen routes (outside shell)
      GoRoute(
        path: '/transaction/add',
        name: 'add-transaction',
        builder: (context, state) => const AddEditTransactionPage(),
      ),
      GoRoute(
        path: '/transaction/edit/:id',
        name: 'edit-transaction',
        builder: (context, state) {
          final transactionId = state.pathParameters['id'];
          return const AddEditTransactionPage();
        },
      ),
    ],
  );
}
