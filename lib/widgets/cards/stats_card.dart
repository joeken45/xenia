import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isLoading;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
    this.icon,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.1),
                cardColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingS),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: cardColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              if (isLoading)
                _buildLoadingIndicator()
              else
                _buildValue(context, cardColor),
              if (subtitle != null) ...[
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (showTrend && trendValue != null) ...[
                const SizedBox(height: AppSizes.paddingS),
                _buildTrendIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 24,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context, Color cardColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: cardColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    if (trendValue == null) return const SizedBox.shrink();

    final isPositive = trendValue! > 0;
    final isNeutral = trendValue! == 0;

    Color trendColor;
    IconData trendIcon;
    String trendText;

    if (isNeutral) {
      trendColor = AppColors.textSecondary;
      trendIcon = Icons.trending_flat;
      trendText = '無變化';
    } else if (isPositive) {
      trendColor = AppColors.success;
      trendIcon = Icons.trending_up;
      trendText = '+${trendValue!.toStringAsFixed(1)}%';
    } else {
      trendColor = AppColors.error;
      trendIcon = Icons.trending_down;
      trendText = '${trendValue!.toStringAsFixed(1)}%';
    }

    return Row(
      children: [
        Icon(
          trendIcon,
          size: 14,
          color: trendColor,
        ),
        const SizedBox(width: AppSizes.paddingXS),
        Text(
          trendText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// 專用的血糖統計卡片
class GlucoseStatsCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final GlucoseStatsType type;
  final VoidCallback? onTap;

  const GlucoseStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatsConfig(type);

    return StatsCard(
      title: title,
      value: value.toStringAsFixed(config.decimals),
      subtitle: unit,
      color: config.color,
      icon: config.icon,
      onTap: onTap,
    );
  }

  _StatsConfig _getStatsConfig(GlucoseStatsType type) {
    switch (type) {
      case GlucoseStatsType.average:
        return _StatsConfig(
          color: _getGlucoseColor(value),
          icon: Icons.trending_flat,
          decimals: 0,
        );
      case GlucoseStatsType.tir:
        return _StatsConfig(
          color: _getTIRColor(value),
          icon: Icons.target,
          decimals: 1,
        );
      case GlucoseStatsType.cv:
        return _StatsConfig(
          color: _getCVColor(value),
          icon: Icons.show_chart,
          decimals: 1,
        );
      case GlucoseStatsType.standardDeviation:
        return _StatsConfig(
          color: AppColors.info,
          icon: Icons.analytics,
          decimals: 1,
        );
      case GlucoseStatsType.highEvents:
        return _StatsConfig(
          color: AppColors.glucoseHigh,
          icon: Icons.arrow_upward,
          decimals: 0,
        );
      case GlucoseStatsType.lowEvents:
        return _StatsConfig(
          color: AppColors.glucoseLow,
          icon: Icons.arrow_downward,
          decimals: 0,
        );
    }
  }

  Color _getGlucoseColor(double value) {
    if (value < 70) return AppColors.glucoseLow;
    if (value > 180) return AppColors.glucoseHigh;
    return AppColors.glucoseNormal;
  }

  Color _getTIRColor(double tir) {
    if (tir >= 70) return AppColors.success;
    if (tir >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Color _getCVColor(double cv) {
    if (cv <= 33) return AppColors.success;
    if (cv <= 36) return AppColors.warning;
    return AppColors.error;
  }
}

// 快速統計行組件
class QuickStatsRow extends StatelessWidget {
  final List<QuickStat> stats;
  final int maxItemsPerRow;

  const QuickStatsRow({
    super.key,
    required this.stats,
    this.maxItemsPerRow = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildRows(),
    );
  }

  List<Widget> _buildRows() {
    final rows = <Widget>[];

    for (int i = 0; i < stats.length; i += maxItemsPerRow) {
      final end = (i + maxItemsPerRow < stats.length)
          ? i + maxItemsPerRow
          : stats.length;
      final rowStats = stats.sublist(i, end);

      rows.add(
        Row(
          children: rowStats.map((stat) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: stat != rowStats.last ? AppSizes.paddingM : 0,
                ),
                child: StatsCard(
                  title: stat.title,
                  value: stat.value,
                  subtitle: stat.subtitle,
                  color: stat.color,
                  icon: stat.icon,
                  onTap: stat.onTap,
                ),
              ),
            );
          }).toList(),
        ),
      );

      if (i + maxItemsPerRow < stats.length) {
        rows.add(const SizedBox(height: AppSizes.paddingM));
      }
    }

    return rows;
  }
}

// 配置類別
class _StatsConfig {
  final Color color;
  final IconData icon;
  final int decimals;

  _StatsConfig({
    required this.color,
    required this.icon,
    required this.decimals,
  });
}

// 快速統計項目
class QuickStat {
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  QuickStat({
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
    this.icon,
    this.onTap,
  });
}

// 血糖統計類型
enum GlucoseStatsType {
  average,
  tir,
  cv,
  standardDeviation,
  highEvents,
  lowEvents,
}