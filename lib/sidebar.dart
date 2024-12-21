import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 34, 120, 218),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Products'),
            onTap: () {
              Navigator.pushNamed(context, '/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text('Add Product'),
            onTap: () {
              Navigator.pushNamed(context, '/addProduct');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Product'),
            onTap: () {
              Navigator.pushNamed(context, '/editProduct');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Invoices'),
            onTap: () {
              Navigator.pushNamed(context, '/invoices');
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pushNamed(context, '/reports');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('BI Charts'),
            onTap: () {
              Navigator.pushNamed(context, '/biCharts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(context, '/changePassword');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('ChatBot'),
            onTap: () {
              Navigator.pushNamed(context, '/chatBot');
            },
          ),
          _buildListTile(
            icon: Icons.logout,
            text: 'Logout',
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
