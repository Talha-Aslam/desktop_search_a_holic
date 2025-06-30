import 'package:flutter/material.dart';

class HealSearchLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool showShadow;
  final BoxFit fit;

  const HealSearchLogo({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 15.0,
    this.showShadow = true,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'images/healsearch_logo.png',
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to old logo if new one isn't found
            return Image.asset(
              'images/logo.png',
              width: width,
              height: height,
              fit: fit,
            );
          },
        ),
      ),
    );
  }
}

class HealSearchBranding extends StatelessWidget {
  final double logoSize;
  final double titleSize;
  final double subtitleSize;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool vertical;

  const HealSearchBranding({
    super.key,
    this.logoSize = 60.0,
    this.titleSize = 24.0,
    this.subtitleSize = 14.0,
    this.titleColor,
    this.subtitleColor,
    this.vertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = HealSearchLogo(
      width: logoSize,
      height: logoSize,
      borderRadius: logoSize * 0.25,
    );

    final titleText = Text(
      'HealSearch',
      style: TextStyle(
        fontSize: titleSize,
        fontWeight: FontWeight.bold,
        color: titleColor ?? Colors.deepPurple,
      ),
    );

    final subtitleText = Text(
      'Retail Management System',
      style: TextStyle(
        fontSize: subtitleSize,
        color: subtitleColor ?? Colors.grey.shade600,
      ),
    );

    if (vertical) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo,
          SizedBox(height: logoSize * 0.2),
          titleText,
          SizedBox(height: logoSize * 0.1),
          subtitleText,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo,
          SizedBox(width: logoSize * 0.3),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText,
              SizedBox(height: logoSize * 0.05),
              subtitleText,
            ],
          ),
        ],
      );
    }
  }
}
