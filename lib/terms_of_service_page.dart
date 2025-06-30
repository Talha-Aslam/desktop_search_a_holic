import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
              'Terms of Service',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      color: themeProvider.cardBackgroundColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HealSearch Terms of Service',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last Updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSection(
                              themeProvider,
                              'Acceptance of Terms',
                              'By using HealSearch POS software, you agree to these terms. '
                                  'If you do not agree, please do not use our service.',
                            ),
                            _buildSection(
                              themeProvider,
                              'Service Description',
                              'HealSearch is a Point of Sale (POS) desktop application that provides:\n\n'
                                  '• Inventory management\n'
                                  '• Sales tracking and reporting\n'
                                  '• Customer management\n'
                                  '• Data backup and export features\n'
                                  '• Business analytics and insights',
                            ),
                            _buildSection(
                              themeProvider,
                              'User Responsibilities',
                              'You are responsible for:\n\n'
                                  '• Maintaining accurate business data\n'
                                  '• Keeping your login credentials secure\n'
                                  '• Complying with applicable laws and regulations\n'
                                  '• Regular data backups (we recommend daily)\n'
                                  '• Reporting any security issues immediately',
                            ),
                            _buildSection(
                              themeProvider,
                              'Data Backup and Loss',
                              'While we provide backup features:\n\n'
                                  '• Users are responsible for their own data backups\n'
                                  '• We recommend regular local and cloud backups\n'
                                  '• We are not liable for data loss due to user error\n'
                                  '• System maintenance may cause temporary downtime\n'
                                  '• Use export features to create additional backups',
                            ),
                            _buildSection(
                              themeProvider,
                              'Limitations of Liability',
                              'Our liability is limited to:\n\n'
                                  '• The amount paid for the software license\n'
                                  '• Direct damages only (no indirect or consequential)\n'
                                  '• Service restoration within reasonable time\n'
                                  '• Some jurisdictions may not allow these limitations',
                            ),
                            _buildSection(
                              themeProvider,
                              'Termination',
                              'This agreement may be terminated:\n\n'
                                  '• By you at any time by discontinuing use\n'
                                  '• By us for violation of these terms\n'
                                  '• Upon expiration of your license\n'
                                  '• With 30 days notice for service changes',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      ThemeProvider themeProvider, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.gradientColors[0],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: themeProvider.textColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
