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

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_checkPasswordStrength);
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigit = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  double _calculatePasswordStrength() {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasUppercase) strength++;
    if (_hasLowercase) strength++;
    if (_hasDigit) strength++;
    if (_hasSpecialChar) strength++;

    return strength / 5;
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.7) return 'Medium';
    return 'Strong';
  }

  Widget _buildPasswordCriteriaRow(bool isMet, String text) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.check_circle_outline,
            color:
                isMet ? Colors.green : themeProvider.textColor.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet
                  ? Colors.green
                  : themeProvider.textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

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
    final double passwordStrength = _calculatePasswordStrength();
    final Color strengthColor = _getStrengthColor(passwordStrength);
    final String strengthText = _getStrengthText(passwordStrength);

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

                                  // Password strength indicator
                                  if (_newPasswordController
                                      .text.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? Colors.black.withOpacity(0.2)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Password Strength: ',
                                                style: TextStyle(
                                                  color:
                                                      themeProvider.textColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                strengthText,
                                                style: TextStyle(
                                                  color: strengthColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Progress bar for password strength
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: passwordStrength,
                                              backgroundColor:
                                                  themeProvider.isDarkMode
                                                      ? Colors.grey.shade700
                                                      : Colors.grey.shade300,
                                              color: strengthColor,
                                              minHeight: 6,
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          // Password criteria checklist
                                          _buildPasswordCriteriaRow(
                                              _hasMinLength,
                                              'At least 8 characters'),
                                          _buildPasswordCriteriaRow(
                                              _hasUppercase,
                                              'At least one uppercase letter (A-Z)'),
                                          _buildPasswordCriteriaRow(
                                              _hasLowercase,
                                              'At least one lowercase letter (a-z)'),
                                          _buildPasswordCriteriaRow(_hasDigit,
                                              'At least one number (0-9)'),
                                          _buildPasswordCriteriaRow(
                                              _hasSpecialChar,
                                              'At least one special character (!@#\$%^&*...)'),
                                        ],
                                      ),
                                    ),
                                  ],

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

                      // We can remove the static password tips section since we now have dynamic feedback
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
}
