import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/sidebar.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // Dummy change password logic
      if (_oldPasswordController.text == "oldpassword" &&
          _newPasswordController.text == _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Password change failed. Make sure old password is correct.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Change Password',
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header with icon
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: themeProvider.gradientColors[0],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Change Your Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please enter your current password and a new password below',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeProvider.textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Password form
                      Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Card(
                          color: themeProvider.cardBackgroundColor,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Old password field
                                  TextFormField(
                                    controller: _oldPasswordController,
                                    decoration: InputDecoration(
                                      labelText: 'Current Password',
                                      labelStyle: TextStyle(
                                        color: themeProvider.textColor
                                            .withOpacity(0.8),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: themeProvider.iconColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureOldPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: themeProvider.iconColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureOldPassword =
                                                !_obscureOldPassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: themeProvider.isDarkMode
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    style: TextStyle(
                                        color: themeProvider.textColor),
                                    obscureText: _obscureOldPassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your current password';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // New password field
                                  TextFormField(
                                    controller: _newPasswordController,
                                    decoration: InputDecoration(
                                      labelText: 'New Password',
                                      labelStyle: TextStyle(
                                        color: themeProvider.textColor
                                            .withOpacity(0.8),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.vpn_key_outlined,
                                        color: themeProvider.iconColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: themeProvider.iconColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: themeProvider.isDarkMode
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    style: TextStyle(
                                        color: themeProvider.textColor),
                                    obscureText: _obscureNewPassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your new password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Confirm password field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm New Password',
                                      labelStyle: TextStyle(
                                        color: themeProvider.textColor
                                            .withOpacity(0.8),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.vpn_key,
                                        color: themeProvider.iconColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: themeProvider.iconColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: themeProvider.isDarkMode
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    style: TextStyle(
                                        color: themeProvider.textColor),
                                    obscureText: _obscureConfirmPassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your new password';
                                      }
                                      if (value !=
                                          _newPasswordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),

                                  // Action buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          // Clear form
                                          _oldPasswordController.clear();
                                          _newPasswordController.clear();
                                          _confirmPasswordController.clear();
                                        },
                                        icon: Icon(
                                          Icons.refresh,
                                          color: themeProvider.textColor
                                              .withOpacity(0.7),
                                        ),
                                        label: Text(
                                          'Reset Form',
                                          style: TextStyle(
                                            color: themeProvider.textColor
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _changePassword,
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
                                        icon: const Icon(Icons.check),
                                        label: const Text(
                                          'Update Password',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Password tips
                      Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.blueGrey.shade900.withOpacity(0.5)
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? Colors.blueGrey.shade700
                                : Colors.blue.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: themeProvider.gradientColors[0],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Password Tips',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildPasswordTip(
                              context,
                              'Use at least 8 characters',
                            ),
                            _buildPasswordTip(
                              context,
                              'Include uppercase and lowercase letters',
                            ),
                            _buildPasswordTip(
                              context,
                              'Include at least one number',
                            ),
                            _buildPasswordTip(
                              context,
                              'Include at least one special character (!@#\$%^&*)',
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
        ],
      ),
    );
  }

  Widget _buildPasswordTip(BuildContext context, String tip) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: themeProvider.gradientColors[0],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              tip,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
