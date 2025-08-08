import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class GlucoseRangeIndicator extends StatelessWidget {
  final double value;
  final double width;
  final double height;
  final bool showLabels;

  const GlucoseRangeIndicator({
    super.key,
    required this.value,
    this.width = 200,
    this.height = 20,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: const LinearGradient(
              colors: [
                AppColors.glucoseLow,
                AppColors.glucoseNormal,
                AppColors.glucoseNormal,
                AppColors.glucoseHigh,
              ],
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: _getIndicatorPosition(value, width),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('低', style: _getLabelStyle()),
              Text('正常', style: _getLabelStyle()),
              Text('高', style: _getLabelStyle()),
            ],
          ),
        ],
      ],
    );
  }

  double _getIndicatorPosition(double value, double width) {
    // 將血糖值 (40-400) 映射到指示器位置 (0-width)
    const minValue = 40.0;
    const maxValue = 400.0;

    final normalizedValue = (value - minValue) / (maxValue - minValue);
    final position = normalizedValue * width;

    return position.clamp(0.0, width - 4); // 減去指示器寬度的一半
  }

  TextStyle _getLabelStyle() {
    return const TextStyle(
      fontSize: 12,
      color: AppColors.textSecondary,
    );
  }
}