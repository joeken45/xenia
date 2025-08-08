import 'package:flutter/material.dart';
import '../../models/glucose_reading.dart';
import '../../utils/constants.dart';

class GlucoseChart extends StatelessWidget {
  final List<GlucoseReading> glucoseReadings;
  final String timeRange;
  final bool showGrid;
  final bool interactive;

  const GlucoseChart({
    super.key,
    required this.glucoseReadings,
    required this.timeRange,
    this.showGrid = true,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (glucoseReadings.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(),
          const SizedBox(height: AppSizes.paddingM),
          Expanded(
            child: _buildSimpleChart(),
          ),
          const SizedBox(height: AppSizes.paddingS),
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: AppSizes.paddingM),
            Text(
              '暫無血糖數據',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '血糖趨勢 ($timeRange)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (glucoseReadings.isNotEmpty)
          Text(
            '${glucoseReadings.length} 筆數據',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildSimpleChart() {
    // 簡化的圖表實現 - 使用 CustomPainter 繪製基本線圖
    return CustomPaint(
      painter: SimpleGlucoseChartPainter(
        readings: glucoseReadings,
        showGrid: showGrid,
      ),
      child: Container(),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('高血糖', AppColors.glucoseHigh, '> 180'),
        _buildLegendItem('正常', AppColors.glucoseNormal, '70-180'),
        _buildLegendItem('低血糖', AppColors.glucoseLow, '< 70'),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              range,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 簡化的圖表繪製器
class SimpleGlucoseChartPainter extends CustomPainter {
  final List<GlucoseReading> readings;
  final bool showGrid;

  SimpleGlucoseChartPainter({
    required this.readings,
    this.showGrid = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    // 繪製網格
    if (showGrid) {
      _drawGrid(canvas, size, gridPaint);
    }

    // 繪製血糖範圍背景
    _drawGlucoseRanges(canvas, size);

    // 繪製血糖線
    _drawGlucoseLine(canvas, size, paint);

    // 繪製數據點
    _drawDataPoints(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    // 繪製水平網格線
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 繪製垂直網格線
    for (int i = 0; i <= 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawGlucoseRanges(Canvas canvas, Size size) {
    // 高血糖範圍 (> 180)
    final highRangePaint = Paint()
      ..color = AppColors.glucoseHigh.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // 低血糖範圍 (< 70)
    final lowRangePaint = Paint()
      ..color = AppColors.glucoseLow.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const minValue = 40.0;
    const maxValue = 300.0;

    // 計算 Y 座標
    final highY = size.height * (1 - (180 - minValue) / (maxValue - minValue));
    final lowY = size.height * (1 - (70 - minValue) / (maxValue - minValue));

    // 繪製高血糖範圍
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, highY),
      highRangePaint,
    );

    // 繪製低血糖範圍
    canvas.drawRect(
      Rect.fromLTRB(0, lowY, size.width, size.height),
      lowRangePaint,
    );
  }

  void _drawGlucoseLine(Canvas canvas, Size size, Paint paint) {
    if (readings.length < 2) return;

    final path = Path();
    const minValue = 40.0;
    const maxValue = 300.0;

    for (int i = 0; i < readings.length; i++) {
      final x = size.width * i / (readings.length - 1);
      final normalizedValue = (readings[i].value - minValue) / (maxValue - minValue);
      final y = size.height * (1 - normalizedValue.clamp(0.0, 1.0));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawDataPoints(Canvas canvas, Size size) {
    const minValue = 40.0;
    const maxValue = 300.0;

    for (int i = 0; i < readings.length; i++) {
      final reading = readings[i];
      final x = size.width * i / (readings.length - 1);
      final normalizedValue = (reading.value - minValue) / (maxValue - minValue);
      final y = size.height * (1 - normalizedValue.clamp(0.0, 1.0));

      // 根據血糖範圍選擇顏色
      Color pointColor;
      if (reading.value > 180) {
        pointColor = AppColors.glucoseHigh;
      } else if (reading.value < 70) {
        pointColor = AppColors.glucoseLow;
      } else {
        pointColor = AppColors.glucoseNormal;
      }

      final pointPaint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, pointPaint);

      // 繪製外圈
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(x, y), 3, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SimpleGlucoseChartPainter oldDelegate) {
    return readings != oldDelegate.readings || showGrid != oldDelegate.showGrid;
  }
}