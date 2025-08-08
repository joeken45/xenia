
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cgm_provider.dart';
import '../../utils/constants.dart';
import '../../utils/glucose_utils.dart';

class GlucoseCard extends StatelessWidget {
  const GlucoseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CGMProvider>(
      builder: (context, cgmProvider, _) {
        final latestReading = cgmProvider.latestReading;

        if (latestReading == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingL),
              child: Center(
                child: Text('暫無血糖數據'),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GlucoseUtils.getGlucoseColor(latestReading.value).withOpacity(0.1),
                  GlucoseUtils.getGlucoseColor(latestReading.value).withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '當前血糖',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        GlucoseUtils.formatTimestamp(latestReading.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        latestReading.value.round().toString(),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: GlucoseUtils.getGlucoseColor(latestReading.value),
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        'mg/dL',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: GlucoseUtils.getTrendColor(latestReading.trendArrow).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              latestReading.trendArrow,
                              style: TextStyle(
                                fontSize: 20,
                                color: GlucoseUtils.getTrendColor(latestReading.trendArrow),
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Text(
                              GlucoseUtils.getTrendDescription(latestReading.trend),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: GlucoseUtils.getTrendColor(latestReading.trendArrow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: GlucoseUtils.getRangeColor(latestReading.range).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Text(
                      GlucoseUtils.getRangeDescription(latestReading.range),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GlucoseUtils.getRangeColor(latestReading.range),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}