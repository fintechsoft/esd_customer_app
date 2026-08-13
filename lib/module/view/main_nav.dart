import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/view/home/home_screen.dart';
import 'package:esdcustomer/module/view/orders/orders_screen.dart';
import 'package:esdcustomer/module/view/products/products_screen.dart';
import 'package:esdcustomer/module/view/profile/profile_screen.dart';
import 'package:esdcustomer/module/view/support/support_screen.dart';
import 'package:flutter/material.dart';

class MainNav extends StatefulWidget {
  const MainNav({Key? key}) : super(key: key);

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    OrdersScreen(),
    ProductsScreen(),
    SupportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppTheme.primary.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primary : AppTheme.textMuted,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          height: 66,
          destinations: [
            _dest(Icons.home_rounded, Icons.home_outlined, 'Home'),
            _dest(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'My Bills'),
            _dest(Icons.storefront_rounded, Icons.storefront_outlined, 'Products'),
            _dest(Icons.support_agent_rounded, Icons.support_agent_outlined, 'Support'),
            _dest(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  NavigationDestination _dest(IconData selected, IconData unselected, String label) {
    return NavigationDestination(
      selectedIcon: Icon(selected, color: AppTheme.primary),
      icon: Icon(unselected, color: AppTheme.textMuted),
      label: label,
    );
  }
}
