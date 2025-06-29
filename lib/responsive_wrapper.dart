import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;
  final bool showWarning;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.minWidth = 1024,
    this.minHeight = 768,
    this.showWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showWarning) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Only show warning if window is significantly smaller than minimum
        // Account for window decorations by using a tolerance
        if (constraints.maxWidth < minWidth - 50 ||
            constraints.maxHeight < minHeight - 50) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Window too small',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please resize window to minimum ${minWidth.toInt()}x${minHeight.toInt()} resolution',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // You could add window resize functionality here if needed
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
