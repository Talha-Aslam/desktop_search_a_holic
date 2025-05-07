import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  _HelpSupportState createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I add a new product?',
      'answer':
          'To add a new product, navigate to the Products section from the sidebar, then click the "Add Product" button. Fill in the product details in the form and submit.'
    },
    {
      'question': 'How can I generate sales reports?',
      'answer':
          'Go to the Reports section from the sidebar. Select the desired time period and report type from the filter options, then view or download the report.'
    },
    {
      'question': 'How to change my password?',
      'answer':
          'Navigate to the Change Password section from the sidebar. Enter your current password followed by your new password and confirmation, then submit the form.'
    },
    {
      'question': 'What should I do if I forget my password?',
      'answer':
          'On the login page, click on "Forgot Password". Enter your registered email address to receive a password reset link.'
    },
    {
      'question': 'How do I process a new order?',
      'answer':
          'Go to the Orders section, click on "New Order". Select customer, add products, quantities, and apply any discounts, then finalize the order.'
    },
    {
      'question': 'Can I customize the dashboard view?',
      'answer':
          'Yes, you can customize the dashboard by going to Settings and selecting your preferences for default view and display options.'
    },
    {
      'question': 'How to backup my data?',
      'answer':
          'Go to Settings, scroll down to the "Notifications & Data" section, and click on "Backup Now" to create a manual backup. You can also enable automatic daily backups.'
    },
  ];

  void _submitSupportRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate sending support request
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the form
        _subjectController.clear();
        _messageController.clear();
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
          'Help & Support',
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
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: themeProvider.gradientColors[0]
                                .withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent,
                            size: 48,
                            color: themeProvider.gradientColors[0],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'How can we help you today?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse through our resources or contact our support team',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions
                  _buildSectionHeader(context, 'Quick Actions'),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildQuickAction(
                          context,
                          'User Guide',
                          Icons.menu_book,
                          () {
                            _launchURL('https://example.com/user-guide');
                          },
                        ),
                        _buildQuickAction(
                          context,
                          'Video Tutorials',
                          Icons.video_library,
                          () {
                            _launchURL('https://example.com/tutorials');
                          },
                        ),
                        _buildQuickAction(
                          context,
                          'Knowledge Base',
                          Icons.lightbulb,
                          () {
                            _launchURL('https://example.com/knowledge-base');
                          },
                        ),
                        _buildQuickAction(
                          context,
                          'Live Chat',
                          Icons.chat,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connecting to live chat...'),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          context,
                          'System Status',
                          Icons.health_and_safety,
                          () {
                            _launchURL('https://example.com/system-status');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // FAQ Section
                  _buildSectionHeader(context, 'Frequently Asked Questions'),
                  Card(
                    color: themeProvider.cardBackgroundColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionPanelList(
                      elevation: 0,
                      expandedHeaderPadding: EdgeInsets.zero,
                      dividerColor: themeProvider.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _faqs[index]['isExpanded'] = !isExpanded;
                        });
                      },
                      children:
                          _faqs.map<ExpansionPanel>((Map<String, dynamic> faq) {
                        return ExpansionPanel(
                          backgroundColor: themeProvider.cardBackgroundColor,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                              title: Text(
                                faq['question'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textColor,
                                ),
                              ),
                            );
                          },
                          body: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              faq['answer'],
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                          isExpanded: faq['isExpanded'] ?? false,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contact Support Form
                  _buildSectionHeader(context, 'Contact Support'),
                  Card(
                    color: themeProvider.cardBackgroundColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send us a message',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Our support team will get back to you within 24 hours',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Subject field
                            TextFormField(
                              controller: _subjectController,
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                labelStyle: TextStyle(
                                  color:
                                      themeProvider.textColor.withOpacity(0.8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: themeProvider.isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                prefixIcon: Icon(
                                  Icons.subject,
                                  color: themeProvider.gradientColors[0],
                                ),
                              ),
                              style: TextStyle(color: themeProvider.textColor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a subject';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Message field
                            TextFormField(
                              controller: _messageController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: 'Message',
                                labelStyle: TextStyle(
                                  color:
                                      themeProvider.textColor.withOpacity(0.8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: themeProvider.isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                alignLabelWithHint: true,
                              ),
                              style: TextStyle(color: themeProvider.textColor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your message';
                                }
                                if (value.length < 10) {
                                  return 'Message must be at least 10 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Submit button
                            Center(
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: themeProvider.gradientColors[0],
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _submitSupportRequest,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            themeProvider.gradientColors[0],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.send),
                                      label: const Text(
                                        'Submit Request',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Support Information
                  _buildSectionHeader(context, 'Additional Support Channels'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSupportCard(
                          context,
                          'Email Support',
                          Icons.email,
                          'Send us an email directly',
                          'support@example.com',
                          () {
                            _launchURL('mailto:support@example.com');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSupportCard(
                          context,
                          'Phone Support',
                          Icons.phone,
                          'Available Mon-Fri, 9AM-5PM',
                          '+1 (555) 123-4567',
                          () {
                            _launchURL('tel:+15551234567');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSupportCard(
                          context,
                          'Community Forum',
                          Icons.forum,
                          'Join our user community',
                          'Discuss tips and tricks',
                          () {
                            _launchURL('https://example.com/community');
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: themeProvider.gradientColors[0],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: themeProvider.gradientColors[0],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    String contact,
    VoidCallback onTap,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      color: themeProvider.cardBackgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: themeProvider.gradientColors[0],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: themeProvider.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                contact,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeProvider.gradientColors[0],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to connect',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: themeProvider.textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
