import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final IconData? icon;
  final String? iconPath;
  final bool isLoading;
  final double? width;
  final double height;

  const SocialButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.black,
    this.icon,
    this.iconPath,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          disabledBackgroundColor: Colors.grey.shade200,
          side: BorderSide(
            color: backgroundColor?.withAlpha(100) ?? Colors.grey.shade300,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(icon, color: textColor, size: 20)
                  else if (iconPath != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.asset(iconPath!, width: 20, height: 20),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
