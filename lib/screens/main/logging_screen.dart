import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cgm_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../generated/l10n.dart';
import '../../models/glucose_reading.dart';

class LoggingScreen extends StatefulWidget {
  const LoggingScreen({super.key});

  @override
  State<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends State<LoggingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGlucoseTab(),
                  _buildFoodTab(),
                  _buildExerciseTab(),
                  _buildInsulinTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      title: Text(S.of(context).logging),
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            // 導航到歷史記錄頁面
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        isScrollable: true,
        tabs: const [
          Tab(text: '血糖', icon: Icon(Icons.water_drop, size: 20)),
          Tab(text: '飲食', icon: Icon(Icons.restaurant, size: 20)),
          Tab(text: '運動', icon: Icon(Icons.fitness_center, size: 20)),
          Tab(text: '胰島素', icon: Icon(Icons.medication, size: 20)),
        ],
      ),
    );
  }

  Widget _buildGlucoseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('手動記錄血糖'),
          const SizedBox(height: AppSizes.paddingM),
          _buildGlucoseForm(),
          const SizedBox(height: AppSizes.paddingL),
          _buildSectionTitle('最近記錄'),
          const SizedBox(height: AppSizes.paddingM),
          _buildRecentGlucoseReadings(),
        ],
      ),
    );
  }

  Widget _buildFoodTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('記錄飲食'),
          const SizedBox(height: AppSizes.paddingM),
          _buildFoodForm(),
          const SizedBox(height: AppSizes.paddingL),
          _buildSectionTitle('今日飲食'),
          const SizedBox(height: AppSizes.paddingM),
          _buildTodayFoodLogs(),
        ],
      ),
    );
  }

  Widget _buildExerciseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('記錄運動'),
          const SizedBox(height: AppSizes.paddingM),
          _buildExerciseForm(),
          const SizedBox(height: AppSizes.paddingL),
          _buildSectionTitle('今日運動'),
          const SizedBox(height: AppSizes.paddingM),
          _buildTodayExerciseLogs(),
        ],
      ),
    );
  }

  Widget _buildInsulinTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('記錄胰島素'),
          const SizedBox(height: AppSizes.paddingM),
          _buildInsulinForm(),
          const SizedBox(height: AppSizes.paddingL),
          _buildSectionTitle('今日用藥'),
          const SizedBox(height: AppSizes.paddingM),
          _buildTodayInsulinLogs(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGlucoseForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: _GlucoseForm(),
      ),
    );
  }

  Widget _buildFoodForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restaurant, size: 32, color: AppColors.primary),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '記錄飲食功能開發中...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomButton(
              text: '新增飲食記錄',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('飲食記錄功能即將推出')),
                );
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fitness_center, size: 32, color: AppColors.primary),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '記錄運動功能開發中...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomButton(
              text: '新增運動記錄',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('運動記錄功能即將推出')),
                );
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsulinForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.medication, size: 32, color: AppColors.primary),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              '記錄胰島素功能開發中...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomButton(
              text: '新增胰島素記錄',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('胰島素記錄功能即將推出')),
                );
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGlucoseReadings() {
    return Consumer<CGMProvider>(
      builder: (context, cgmProvider, _) {
        if (cgmProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingL),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final recentReadings = cgmProvider.glucoseReadings.take(5).toList();

        if (recentReadings.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      '暫無血糖記錄',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentReadings.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final reading = recentReadings[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getGlucoseColor(reading.value).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      reading.value.round().toString(),
                      style: TextStyle(
                        color: _getGlucoseColor(reading.value),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                title: Text('${reading.value.round()} mg/dL'),
                subtitle: Text(_formatTimestamp(reading.timestamp)),
                trailing: Text(
                  reading.trendArrow,
                  style: TextStyle(
                    fontSize: 16,
                    color: _getTrendColor(reading.trend),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTodayFoodLogs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                '今日暫無飲食記錄',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayExerciseLogs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                '今日暫無運動記錄',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayInsulinLogs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.medication_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                '今日暫無胰島素記錄',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGlucoseColor(double value) {
    if (value < AppStrings.glucoseLowThreshold) {
      return AppColors.glucoseLow;
    } else if (value > AppStrings.glucoseHighThreshold) {
      return AppColors.glucoseHigh;
    } else {
      return AppColors.glucoseNormal;
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

// 血糖記錄表單組件
class _GlucoseForm extends StatefulWidget {
  @override
  State<_GlucoseForm> createState() => _GlucoseFormState();
}

class _GlucoseFormState extends State<_GlucoseForm> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _notesController = TextEditingController();

  GlucoseTrend _selectedTrend = GlucoseTrend.stable;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, size: 32, color: AppColors.primary),
              const SizedBox(width: AppSizes.paddingM),
              Text(
                '手動血糖記錄',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          NumberTextField(
            controller: _glucoseController,
            labelText: '血糖值',
            hintText: '請輸入血糖值',
            suffix: 'mg/dL',
            validator: Validators.validateGlucoseValue,
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildTrendSelector(),
          const SizedBox(height: AppSizes.paddingM),
          _buildDateTimeSelector(),
          const SizedBox(height: AppSizes.paddingM),
          MultilineTextField(
            controller: _notesController,
            labelText: '備註',
            hintText: '記錄相關備註（選填）',
            maxLines: 3,
            validator: Validators.validateNotes,
          ),
          const SizedBox(height: AppSizes.paddingL),
          CustomButton(
            text: '儲存記錄',
            onPressed: _isLoading ? null : _handleSaveGlucose,
            isLoading: _isLoading,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '血糖趨勢',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Row(
            children: GlucoseTrend.values.map((trend) {
              final isSelected = trend == _selectedTrend;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTrend = trend;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getTrendArrow(trend),
                          style: TextStyle(
                            fontSize: 20,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTrendDescription(trend),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    '${_selectedDateTime.month}/${_selectedDateTime.day}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.textSecondary),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _handleSaveGlucose() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final glucoseValue = double.parse(_glucoseController.text);
      final cgmProvider = Provider.of<CGMProvider>(context, listen: false);

      await cgmProvider.addManualGlucoseReading(
        value: glucoseValue,
        timestamp: _selectedDateTime,
        trend: _selectedTrend,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('血糖記錄已儲存'),
            backgroundColor: AppColors.success,
          ),
        );

        // 清空表單
        _glucoseController.clear();
        _notesController.clear();
        setState(() {
          _selectedTrend = GlucoseTrend.stable;
          _selectedDateTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('儲存失敗: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTrendArrow(GlucoseTrend trend) {
    switch (trend) {
      case GlucoseTrend.rapidlyRising:
        return '↑↑';
      case GlucoseTrend.rising:
        return '↑';
      case GlucoseTrend.stable:
        return '→';
      case GlucoseTrend.falling:
        return '↓';
      case GlucoseTrend.rapidlyFalling:
        return '↓↓';
    }
  }

  String _getTrendDescription(GlucoseTrend trend) {
    switch (trend) {
      case GlucoseTrend.rapidlyRising:
        return '快速上升';
      case GlucoseTrend.rising:
        return '上升';
      case GlucoseTrend.stable:
        return '穩定';
      case GlucoseTrend.falling:
        return '下降';
      case GlucoseTrend.rapidlyFalling:
        return '快速下降';
    }
  }