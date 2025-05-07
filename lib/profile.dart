import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadDummyProfileData();
  }

  void _loadDummyProfileData() {
    // Dummy data for profile
    var dummyProfileData = {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "phone": "123-456-7890",
      "address": "123 Main Street, City, Country",
      "role": "Administrator",
    };

    _nameController.text = dummyProfileData['name']!;
    _emailController.text = dummyProfileData['email']!;
    _phoneController.text = dummyProfileData['phone']!;
    _addressController.text = dummyProfileData['address']!;
    _roleController.text = dummyProfileData['role']!;
  }

  void _saveProfile() {
    // Toggle edit mode off
    setState(() {
      _isEditing = false;
    });

    // Dummy save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully!'),
        backgroundColor: Colors.green,
      ),
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
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
          const SizedBox(width: 8),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Profile Picture
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('images/profile.jpg'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _roleController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile Information
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Information Cards
                    Card(
                      color: themeProvider.cardBackgroundColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildProfileField(
                              context: context,
                              label: 'Full Name',
                              controller: _nameController,
                              icon: Icons.person,
                              isEditable: _isEditing,
                            ),
                            const Divider(),
                            _buildProfileField(
                              context: context,
                              label: 'Email',
                              controller: _emailController,
                              icon: Icons.email,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const Divider(),
                            _buildProfileField(
                              context: context,
                              label: 'Phone',
                              controller: _phoneController,
                              icon: Icons.phone,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                            const Divider(),
                            _buildProfileField(
                              context: context,
                              label: 'Address',
                              controller: _addressController,
                              icon: Icons.location_on,
                              isEditable: _isEditing,
                            ),
                            const Divider(),
                            _buildProfileField(
                              context: context,
                              label: 'Role',
                              controller: _roleController,
                              icon: Icons.work,
                              isEditable: false, // Role should not be editable
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    if (_isEditing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.gradientColors[0],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: () {
                              // Reset values to original
                              _loadDummyProfileData();
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(
                              foregroundColor: themeProvider.textColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),

                    // Account settings section
                    const SizedBox(height: 32),
                    Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Settings cards
                    Card(
                      color: themeProvider.cardBackgroundColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.lock,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Change Password',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: themeProvider.textColor.withOpacity(0.5),
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/changePassword');
                            },
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: themeProvider.isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Notification Settings',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: themeProvider.textColor.withOpacity(0.5),
                              size: 16,
                            ),
                            onTap: () {
                              // Show notification settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Notification settings coming soon'),
                                ),
                              );
                            },
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: themeProvider.isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                          ListTile(
                            leading: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: themeProvider.gradientColors[0],
                            ),
                            title: Text(
                              'Theme Settings',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              activeColor: themeProvider.gradientColors[0],
                              onChanged: (_) => themeProvider.toggleTheme(),
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
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isEditable = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: themeProvider.gradientColors[0],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                isEditable
                    ? TextFormField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.textColor,
                        ),
                        keyboardType: keyboardType,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          filled: true,
                          fillColor: themeProvider.isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: themeProvider.gradientColors[0],
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        controller.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.textColor,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
