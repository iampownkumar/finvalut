import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:finvault/core/providers/app_state_provider.dart';
import 'package:finvault/features/transactions/presentation/pages/add_edit_transaction_page.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            // If there's a page to pop in the router stack, let GoRouter handle it first.
            if (context.canPop()) {
              context.pop();
              return;
            }
            // Handle system back: navigate to Home if not on home; on home require double back
            if (didPop) return;
            if (appState.currentBottomNavIndex != 0) {
              appState.setBottomNavIndex(0);
              context.go('/home');
              return;
            }
            final now = DateTime.now();
            if (_lastBackPress == null ||
                now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
              _lastBackPress = now;
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Press back again to exit'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            // Allow app to exit
            SystemNavigator.pop();
          },
          child: Scaffold(
            body: widget.child,
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: appState.currentBottomNavIndex,
              onTap: (index) {
                appState.setBottomNavIndex(index);
                _navigateToPage(context, index);
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Accounts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card_outlined),
                  activeIcon: Icon(Icons.credit_card),
                  label: 'Cards',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_outlined),
                  activeIcon: Icon(Icons.account_balance),
                  label: 'Loans',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // Navigate to add transaction page with proper back navigation
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddEditTransactionPage(),
                  ),
                );

                // If transaction was added successfully, refresh home data
                if (result == true) {
                  // Trigger a rebuild of current page
                  if (appState.currentBottomNavIndex == 0) {
                    // We're on home page, refresh it
                    context.go('/home');
                  }
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/accounts');
        break;
      case 2:
        context.go('/analytics');
        break;
      case 3:
        context.go('/credit-cards');
        break;
      case 4:
        context.go('/loans');
        break;
    }
  }
}
