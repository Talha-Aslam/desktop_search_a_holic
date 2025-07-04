import 'package:provider/provider.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/imports.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  String validateLogin() {
    if (email.text == "") {
      return "emptyEmail"; // Error Message
    } else if (password.text == "") {
      return "emptyPassword"; // Error Message
    } else {
      return "valid"; // Valid Message
    }
  }

  Future<void> checkLogin(BuildContext context) async {
    String validationMessage = validateLogin();
    if (validationMessage == "valid") {
      setState(() {
        _isLoading = true;
      });

      try {
        // Attempt to sign in with Firebase Auth
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );

        if (userCredential.user != null) {
          // Login successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors
        String errorMessage = 'An error occurred during login';

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email address';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled. Contact support';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later';
            break;
          case 'invalid-credential':
            errorMessage =
                'Invalid email or password. Please check your credentials';
            break;
          case 'network-request-failed':
            errorMessage =
                'Network error. Please check your internet connection';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password sign-in is not enabled';
            break;
          default:
            errorMessage = 'Login failed: ${e.message ?? 'Unknown error'}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Show validation error
      String fieldName =
          validationMessage == "emptyEmail" ? "email" : "password";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your $fieldName'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    // Define text colors based on the current theme
    final textColor = Colors.white;

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
          'Login',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: themeProvider.scaffoldBackgroundColor,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: size.width > 600 ? 600 : size.width * 0.9,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  colors: themeProvider.gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Login logo or icon
                    Icon(
                      Icons.account_circle,
                      size: 80,
                      color: textColor,
                    ),
                    const SizedBox(height: 16.0),
                    // Login title
                    Text(
                      'Login Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Email field
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: 'Enter your email address',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: !themeProvider
                            .isDarkMode, // Only fill background in light mode
                        fillColor: !themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : // Darker background for light mode
                            Colors.transparent, // Keep transparent in dark mode
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Password field
                    TextFormField(
                      controller: password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter your password',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                        errorStyle: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: !themeProvider
                            .isDarkMode, // Only fill background in light mode
                        fillColor: !themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : // Darker background for light mode
                            Colors.transparent, // Keep transparent in dark mode
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await Navigator.pushNamed(
                                context, '/forgetPassword');
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error navigating to password reset: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    themeProvider.gradientColors[0],
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () => checkLogin(context),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: themeProvider.gradientColors[0],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16.0),
                    // Registration Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/registration');
                          },
                          child: const Text(
                            'Register Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
