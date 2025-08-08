
class TrendArrow extends StatelessWidget {
  final GlucoseTrend trend;
  final double size;
  final Color? color;

  const TrendArrow({
    super.key,
    required this.trend,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getTrendIcon(trend),
      size: size,
      color: color ?? _getTrendColor(trend),
    );
  }

  IconData _getTrendIcon(GlucoseTrend trend) {
    switch (trend) {
      case GlucoseTrend.rapidlyRising:
        return Icons.north;
      case GlucoseTrend.rising:
        return Icons.north_east;
      case GlucoseTrend.stable:
        return Icons.east;
      case GlucoseTrend.falling:
        return Icons.south_east;
      case GlucoseTrend.rapidlyFalling:
        return Icons.south;
    }
  }

  Color _getTrendColor(GlucoseTrend trend) {
    switch (trend) {
      case GlucoseTrend.rapidlyRising:
      case GlucoseTrend.rising:
        return AppColors.trendUp;
      case GlucoseTrend.stable:
        return AppColors.trendStable;
      case GlucoseTrend.falling:
      case GlucoseTrend.rapidlyFalling:
        return AppColors.trendDown;
    }
  }
}
