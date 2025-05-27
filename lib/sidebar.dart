import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      backgroundColor:
          themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 8,
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/logo.png'),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Search-A-Holic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Desktop Application',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Theme toggle button
          Container(
            color: themeProvider.isDarkMode
                ? const Color(0xFF252525)
                : const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  activeColor: themeProvider.gradientColors[0],
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: themeProvider.isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade300,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildListTile(
                  context: context,
                  icon: Icons.dashboard,
                  text: 'Dashboard',
                  route: '/dashboard',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.person,
                  text: 'Profile',
                  route: '/profile',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.shopping_cart,
                  text: 'Products',
                  route: '/products',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.add_shopping_cart,
                  text: 'Add Product',
                  route: '/addProduct',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.edit,
                  text: 'Edit Product',
                  route: '/editProduct',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.point_of_sale,
                  text: 'Point of Sale',
                  route: '/pos',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.receipt,
                  text: 'Invoices',
                  route: '/invoices',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.report,
                  text: 'Reports',
                  route: '/reports',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.settings,
                  text: 'Settings',
                  route: '/settings',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.lock,
                  text: 'Change Password',
                  route: '/changePassword',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.chat,
                  text: 'ChatBot',
                  route: '/chatBot',
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.logout,
                  text: 'Logout',
                  route: '/login',
                  isLogout: true,
                ),
              ],
            ),
          ),
          // User info at bottom of sidebar
          Container(
            color: themeProvider.isDarkMode
                ? const Color(0xFF252525)
                : const Color(0xFFF5F5F5),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('images/profile.jpg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'admin@example.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String route,
    bool isLogout = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : themeProvider.isDarkMode
                ? Colors.white70
                : themeProvider.gradientColors[0],
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : themeProvider.isDarkMode
                  ? Colors.white
                  : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        if (isLogout) {
          Navigator.pushNamedAndRemoveUntil(
              context, route, (Route<dynamic> route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      hoverColor: themeProvider.isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade200,
      tileColor:
          themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
    );
  }
}
