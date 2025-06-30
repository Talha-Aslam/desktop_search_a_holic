import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
              'Privacy Policy',
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
                              'HealSearch Privacy Policy',
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
                              'Data Collection',
                              'We collect the following information to provide our POS services:\n\n'
                                  '• Business account information (email, business name)\n'
                                  '• Product inventory data (names, prices, quantities, categories)\n'
                                  '• Sales transaction records (customer information, purchase details)\n'
                                  '• System usage analytics and backup logs\n'
                                  '• Authentication credentials (encrypted)',
                            ),
                            _buildSection(
                              themeProvider,
                              'Data Storage and Security',
                              'Your data security is our priority:\n\n'
                                  '• All data is stored securely using Firebase Cloud Firestore\n'
                                  '• Passwords are encrypted and never stored in plain text\n'
                                  '• Local backups are created in encrypted format\n'
                                  '• Data transmission is secured using HTTPS/SSL protocols\n'
                                  '• Regular security audits and updates are performed',
                            ),
                            _buildSection(
                              themeProvider,
                              'Data Usage',
                              'Your data is used solely for:\n\n'
                                  '• Managing your business inventory and sales\n'
                                  '• Generating business reports and analytics\n'
                                  '• Creating automatic backups for data protection\n'
                                  '• Providing customer support when requested\n'
                                  '• Improving our services based on usage patterns',
                            ),
                            _buildSection(
                              themeProvider,
                              'Data Sharing',
                              'We do NOT share your data with third parties except:\n\n'
                                  '• Firebase/Google Cloud services for data storage and authentication\n'
                                  '• When required by law or legal proceedings\n'
                                  '• With your explicit consent for specific services\n'
                                  '• Anonymous, aggregated data for service improvement',
                            ),
                            _buildSection(
                              themeProvider,
                              'Your Rights',
                              'You have the right to:\n\n'
                                  '• Access all your stored data\n'
                                  '• Export your data in CSV/JSON format\n'
                                  '• Delete your account and all associated data\n'
                                  '• Modify or update your information\n'
                                  '• Request data portability\n'
                                  '• Opt-out of non-essential data processing',
                            ),
                            _buildSection(
                              themeProvider,
                              'Data Retention',
                              'Data retention policies:\n\n'
                                  '• Active business data is retained while your account is active\n'
                                  '• Backup logs are automatically cleaned after 30 days\n'
                                  '• Deleted data is permanently removed within 30 days\n'
                                  '• Account closure results in complete data deletion within 90 days\n'
                                  '• Legal requirements may extend retention periods',
                            ),
                            _buildSection(
                              themeProvider,
                              'Local Storage',
                              'We use local storage for:\n\n'
                                  '• User authentication tokens\n'
                                  '• Application preferences and settings\n'
                                  '• Temporary data caching for offline functionality\n'
                                  '• Theme and UI customization preferences\n'
                                  '• All local data is encrypted and secured',
                            ),
                            _buildSection(
                              themeProvider,
                              'Contact Information',
                              'For privacy-related questions or requests:\n\n'
                                  '• Email: privacy@healsearch.com\n'
                                  '• Response time: Within 48 hours\n'
                                  '• Data requests: Processed within 30 days\n'
                                  '• Address: [Your Business Address]',
                            ),
                            _buildSection(
                              themeProvider,
                              'Policy Updates',
                              'This privacy policy may be updated periodically:\n\n'
                                  '• Users will be notified of significant changes\n'
                                  '• Continued use implies acceptance of updates\n'
                                  '• Previous versions available upon request\n'
                                  '• Major changes require explicit consent',
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: themeProvider.gradientColors[0]
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: themeProvider.gradientColors[0]
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: themeProvider.gradientColors[0],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your privacy and data security are our top priorities. '
                                      'We are committed to transparent data practices and protecting your business information.',
                                      style: TextStyle(
                                        color: themeProvider.textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
