import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = true;
  double _fontSize = 13.0;

  final List<Map<String, dynamic>> _presetThemes = [
    {
      'name': 'Default Blue',
      'primary': Colors.blue,
      'secondary': Colors.lightBlueAccent,
    },
    {
      'name': 'Purple Elegance',
      'primary': Colors.purple,
      'secondary': Colors.purpleAccent,
    },
    {
      'name': 'Forest Green',
      'primary': Colors.green,
      'secondary': Colors.lightGreen,
    },
    {
      'name': 'Sunset Orange',
      'primary': Colors.deepOrange,
      'secondary': Colors.orange,
    },
    {
      'name': 'Ruby Red',
      'primary': Colors.red,
      'secondary': Colors.redAccent,
    },
    {
      'name': 'Teal Calm',
      'primary': Colors.teal,
      'secondary': Colors.tealAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize font size from theme provider with clamping
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _fontSize = themeProvider.fontSize.clamp(10.0, 17.0);
    // Load settings after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? true;
      // Clamp font size to the valid range (10-17)
      _fontSize = themeProvider.fontSize.clamp(10.0, 17.0);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('auto_backup_enabled', _autoBackupEnabled);

    // Update font size through theme provider
    await themeProvider.setFontSize(_fontSize);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    setState(() {
      _notificationsEnabled = true;
      _autoBackupEnabled = true;
      _fontSize = 13.0;
    });

    await prefs.clear();
    // Reset font size in theme provider
    await themeProvider.setFontSize(13.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
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
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text(
                      'This will reset all settings to their default values.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _resetSettings();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save settings',
            onPressed: _saveSettings,
          ),
        ],
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
                  // Theme Section
                  _buildSectionHeader(context, 'Appearance'),
                  Card(
                    color: themeProvider.cardBackgroundColor,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Theme Mode Toggle
                          ListTile(
                            leading: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Theme Mode',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              themeProvider.isDarkMode
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.7),
                              ),
                            ),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              activeColor: themeProvider.gradientColors[0],
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ),

                          const Divider(),

                          // Theme Colors
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, bottom: 8, top: 8),
                            child: Text(
                              'Theme Colors',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textColor,
                              ),
                            ),
                          ),

                          // Theme Presets with fixed height to prevent overflow
                          Container(
                            height: 90, // Increased height to avoid overflow
                            margin: const EdgeInsets.only(
                                bottom: 8), // Added margin
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _presetThemes.length,
                              itemBuilder: (context, index) {
                                final theme = _presetThemes[index];
                                bool isSelected =
                                    themeProvider.gradientColors[0] ==
                                        theme['primary'];

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      themeProvider.setGradientColors([
                                        theme['primary'],
                                        theme['secondary'],
                                      ]);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Added to minimize column height
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme['primary'],
                                                theme['secondary'],
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          theme['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: themeProvider.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const Divider(),

                          // Font Size
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.text_fields,
                                  color: themeProvider.gradientColors[0],
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Font Size: ${_fontSize.clamp(10.0, 17.0).toInt()}',
                                  style: TextStyle(
                                    color: themeProvider.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: _fontSize.clamp(10.0, 17.0),
                            min: 10,
                            max: 17,
                            divisions: 7,
                            activeColor: themeProvider.gradientColors[0],
                            inactiveColor: themeProvider.gradientColors[0]
                                .withOpacity(0.3),
                            label:
                                _fontSize.clamp(10.0, 17.0).toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                _fontSize = value;
                              });
                              // Debug: print the font size change
                              print('Font size changed to: $value');
                              // Immediately apply font size change
                              themeProvider.setFontSize(value);
                            },
                          ),

                          // Text Size Preview
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? Colors.black26
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'This is a preview of your selected text size',
                                  style: themeProvider.bodyTextStyle,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Current font size: ${themeProvider.fontSize.toStringAsFixed(1)}px',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.textColor
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Notifications & Data
                  _buildSectionHeader(context, 'Notifications & Data'),
                  Card(
                    color: themeProvider.cardBackgroundColor,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Notifications Toggle
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Notifications',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _notificationsEnabled
                                  ? 'Notifications are enabled'
                                  : 'Notifications are disabled',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.7),
                              ),
                            ),
                            trailing: Switch(
                              value: _notificationsEnabled,
                              activeColor: themeProvider.gradientColors[0],
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                            ),
                          ),

                          const Divider(),

                          // Auto Backup Toggle
                          ListTile(
                            leading: Icon(
                              Icons.backup,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Auto Backup',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _autoBackupEnabled
                                  ? 'Daily automatic backup enabled'
                                  : 'Daily automatic backup disabled',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.7),
                              ),
                            ),
                            trailing: Switch(
                              value: _autoBackupEnabled,
                              activeColor: themeProvider.gradientColors[0],
                              onChanged: (value) {
                                setState(() {
                                  _autoBackupEnabled = value;
                                });
                              },
                            ),
                          ),

                          const Divider(),

                          // Manual Backup Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Simulate backup process
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Backup created successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    themeProvider.gradientColors[0],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.backup),
                              label: const Text('Create Backup Now'),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor:
                                        themeProvider.cardBackgroundColor,
                                    title: Text(
                                      'Export Data',
                                      style: TextStyle(
                                          color: themeProvider.textColor),
                                    ),
                                    content: Text(
                                      'Choose a format to export your data',
                                      style: TextStyle(
                                          color: themeProvider.textColor),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Exporting data as CSV...'),
                                            ),
                                          );
                                        },
                                        child: const Text('CSV'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Exporting data as Excel...'),
                                            ),
                                          );
                                        },
                                        child: const Text('Excel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Exporting data as PDF...'),
                                            ),
                                          );
                                        },
                                        child: const Text('PDF'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                                foregroundColor: themeProvider.textColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.download),
                              label: const Text('Export Data'),
                            ),
                          ),

                          // View Backup History Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/backup-history');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.gradientColors[0]
                                    .withOpacity(0.8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.history),
                              label: const Text('View Backup History'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // About Section
                  _buildSectionHeader(context, 'About'),
                  Card(
                    color: themeProvider.cardBackgroundColor,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.info,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'App Version',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '1.0.0',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.update,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Check for Updates',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: themeProvider.textColor.withOpacity(0.7),
                            ),
                            onTap: () {
                              // Show a simulated update check dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor:
                                      themeProvider.cardBackgroundColor,
                                  title: Text(
                                    'Check for Updates',
                                    style: TextStyle(
                                        color: themeProvider.textColor),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: themeProvider.gradientColors[0],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Checking for updates...',
                                        style: TextStyle(
                                            color: themeProvider.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              // Simulate update check
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor:
                                        themeProvider.cardBackgroundColor,
                                    title: Text(
                                      'Update Status',
                                      style: TextStyle(
                                          color: themeProvider.textColor),
                                    ),
                                    content: Text(
                                      'You are running the latest version.',
                                      style: TextStyle(
                                          color: themeProvider.textColor),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.description,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Terms of Service',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: themeProvider.textColor.withOpacity(0.7),
                            ),
                            onTap: () {
                              // Navigate to Terms of Service page
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.privacy_tip,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: themeProvider.textColor.withOpacity(0.7),
                            ),
                            onTap: () {
                              // Navigate to Privacy Policy page
                            },
                          ),
                          const Divider(),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 16.0),
                              child: Text(
                                '© 2025 HealSearch. All rights reserved.',
                                style: TextStyle(
                                  color:
                                      themeProvider.textColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
}
