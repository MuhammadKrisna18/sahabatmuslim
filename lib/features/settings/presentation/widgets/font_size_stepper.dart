import 'package:flutter/material.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class FontSizeStepper extends StatelessWidget {
  final String title;
  final double currentSize;
  final double minSize;
  final double maxSize;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final String unit;

  const FontSizeStepper({
    super.key,
    required this.title,
    required this.currentSize,
    required this.minSize,
    required this.maxSize,
    required this.onDecrease,
    required this.onIncrease,
    this.unit = 'pt',
  });

  @override
  Widget build(BuildContext context) {
    final bool canDecrease = currentSize > minSize;
    final bool canIncrease = currentSize < maxSize;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  context: context,
                  icon: Icons.remove_rounded,
                  enabled: canDecrease,
                  onPressed: onDecrease,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 54),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  child: Text(
                    '${currentSize.round()} $unit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ),
                _buildButton(
                  context: context,
                  icon: Icons.add_rounded,
                  enabled: canIncrease,
                  onPressed: onIncrease,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? context.primaryColor
                : context.textSecondaryColor.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
