import 'package:flutter/material.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.scaffoldBackgroundColor,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      color: themeProvider.cardBackgroundColor,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.dashboard,
                                  size: 36,
                                  color: themeProvider.gradientColors[0],
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Welcome to the Dashboard',
                                  style: TextStyle(
                                    color: themeProvider.textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'Here you can manage your products, view reports, and more.',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/reports');
                              },
                              icon: const Icon(Icons.analytics),
                              label: const Text('View Reports'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    themeProvider.gradientColors[0],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics Row
                    Text(
                      'Statistics',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          size.width > 1200 ? 4 : (size.width > 800 ? 3 : 2),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          context,
                          'Products',
                          '120',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Orders',
                          '43',
                          Icons.shopping_basket,
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          'Revenue',
                          '\$5,240',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          'Customers',
                          '68',
                          Icons.people,
                          Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent Items
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity Cards
                    Card(
                      color: themeProvider.cardBackgroundColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.blue.shade800
                              : Colors.blue.shade100,
                          child: Icon(
                            Icons.shopping_cart,
                            color: themeProvider.isDarkMode
                                ? Colors.blue.shade100
                                : Colors.blue.shade800,
                          ),
                        ),
                        title: Text(
                          'New Product Added',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Paracetamol 500mg - 10 minutes ago',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: themeProvider.textColor.withOpacity(0.5),
                          size: 16,
                        ),
                      ),
                    ),

                    Card(
                      color: themeProvider.cardBackgroundColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.green.shade800
                              : Colors.green.shade100,
                          child: Icon(
                            Icons.shopping_bag,
                            color: themeProvider.isDarkMode
                                ? Colors.green.shade100
                                : Colors.green.shade800,
                          ),
                        ),
                        title: Text(
                          'New Order Received',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Order #1234 - 25 minutes ago',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: themeProvider.textColor.withOpacity(0.5),
                          size: 16,
                        ),
                      ),
                    ),

                    Card(
                      color: themeProvider.cardBackgroundColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.purple.shade800
                              : Colors.purple.shade100,
                          child: Icon(
                            Icons.person_add,
                            color: themeProvider.isDarkMode
                                ? Colors.purple.shade100
                                : Colors.purple.shade800,
                          ),
                        ),
                        title: Text(
                          'New User Registration',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'John Smith - 1 hour ago',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: themeProvider.textColor.withOpacity(0.5),
                          size: 16,
                        ),
                      ),
                    ),

                    Card(
                      color: themeProvider.cardBackgroundColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.orange.shade800
                              : Colors.orange.shade100,
                          child: Icon(
                            Icons.payment,
                            color: themeProvider.isDarkMode
                                ? Colors.orange.shade100
                                : Colors.orange.shade800,
                          ),
                        ),
                        title: Text(
                          'Payment Received',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '\$320.00 for Order #1230 - 2 hours ago',
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: themeProvider.textColor.withOpacity(0.5),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      color: themeProvider.cardBackgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
