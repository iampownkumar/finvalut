import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/credit_cards/presentation/pages/credit_cards_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart'; // Add this
import '../../features/transactions/presentation/pages/add_edit_transaction_page.dart';
import '../../shared/presentation/widgets/main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
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
            path: '/analytics', // Add this route
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
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
          return const AddEditTransactionPage();
        },
      ),
    ],
  );
}
