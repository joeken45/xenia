import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../models/exercise_log.dart';

class ExerciseLogDialog extends StatefulWidget {
  final ExerciseLog? existingLog;

  const ExerciseLogDialog({
    super.key,
    this.existingLog,
  });

  @override
  State<ExerciseLogDialog> createState() => _ExerciseLogDialogState();
}

class _ExerciseLogDialogState extends State<ExerciseLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseTypeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();

  ExerciseIntensity _selectedIntensity = ExerciseIntensity.moderate;
  ExerciseCategory _selectedCategory = ExerciseCategory.other;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  final List<String> _commonExercises = [
    '走路', '跑步', '騎腳踏車', '游泳', '瑜伽', '重量訓練', '有氧運動',
    '爬山', '羽毛球', '桌球', '籃球', '足球', '網球', '伸展運動', '跳舞'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _initializeWithExistingLog();
    }
  }

  void _initializeWithExistingLog() {
    final log = widget.existingLog!;
    _exerciseTypeController.text = log.exerciseType;
    _durationController.text = log.duration.toString();
    _caloriesController.text = log.caloriesBurned?.toString() ?? '';
    _distanceController.text = log.distance?.toString() ?? '';
    _heartRateController.text = log.heartRate?.toString() ?? '';
    _notesController.text = log.notes ?? '';
    _selectedIntensity = log.intensity;
    _selectedCategory = log.category;
    _selectedDateTime = log.timestamp;
  }

  @override
  void dispose() {
    _exerciseTypeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSizes.paddingM),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExerciseTypeField(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildCategorySelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildDurationField(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildIntensitySelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildAdditionalFields(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildDateTimeSelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildNotesField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusL),
          topRight: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              widget.existingLog != null ? '編輯運動記錄' : '新增運動記錄',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _exerciseTypeController,
          labelText: '運動類型',
          hintText: '請輸入運動類型',
          prefixIcon: Icons.sports,
          validator: Validators.validateExerciseType,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonExercises.map((exercise) {
            return InkWell(
              onTap: () {
                _exerciseTypeController.text = exercise;
                _updateCategoryFromExercise(exercise);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  exercise,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '運動分類',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExerciseCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getCategoryIcon(category),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryDescription(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    return NumberTextField(
      controller: _durationController,
      labelText: '運動時間',
      hintText: '0',
      suffix: '分鐘',
      decimalPlaces: 0,
      validator: Validators.validateExerciseDuration,
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '運動強度',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Row(
            children: ExerciseIntensity.values.map((intensity) {
              final isSelected = intensity == _selectedIntensity;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIntensity = intensity;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _getIntensityColor(intensity) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getIntensityIcon(intensity),
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getIntensityDescription(intensity),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
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

  Widget _buildAdditionalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '其他資訊（選填）',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: NumberTextField(
                controller: _caloriesController,
                labelText: '消耗熱量',
                hintText: '0',
                suffix: 'kcal',
                decimalPlaces: 0,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: NumberTextField(
                controller: _distanceController,
                labelText: '距離',
                hintText: '0',
                suffix: 'km',
                decimalPlaces: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        NumberTextField(
          controller: _heartRateController,
          labelText: '平均心率',
          hintText: '0',
          suffix: 'bpm',
          decimalPlaces: 0,
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '運動時間',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
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
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return MultilineTextField(
      controller: _notesController,
      labelText: '備註',
      hintText: '記錄相關備註（選填）',
      maxLines: 3,
      validator: Validators.validateNotes,
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusL),
          bottomRight: Radius.circular(AppSizes.radiusL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: '取消',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: CustomButton(
              text: widget.existingLog != null ? '更新' : '儲存',
              onPressed: _isLoading ? null : _saveExerciseLog,
              isLoading: _isLoading,
              icon: Icons.save,
            ),
          ),
        ],
      ),
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

  void _updateCategoryFromExercise(String exercise) {
    setState(() {
      if (exercise.contains('跑') || exercise.contains('走')) {
        _selectedCategory = ExerciseCategory.running;
      } else if (exercise.contains('騎') || exercise.contains('腳踏車')) {
        _selectedCategory = ExerciseCategory.cycling;
      } else if (exercise.contains('游泳')) {
        _selectedCategory = ExerciseCategory.swimming;
      } else if (exercise.contains('瑜伽')) {
        _selectedCategory = ExerciseCategory.yoga;
      } else if (exercise.contains('重量') || exercise.contains('肌力')) {
        _selectedCategory = ExerciseCategory.strength;
      } else if (exercise.contains('球') || exercise.contains('網球') || exercise.contains('羽毛球')) {
        _selectedCategory = ExerciseCategory.sports;
      } else if (exercise.contains('有氧')) {
        _selectedCategory = ExerciseCategory.cardio;
      } else {
        _selectedCategory = ExerciseCategory.other;
      }
    });
  }

  Future<void> _saveExerciseLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final exerciseLog = ExerciseLog(
        id: widget.existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // 應該從認證狀態獲取
        timestamp: _selectedDateTime,
        exerciseType: _exerciseTypeController.text.trim(),
        duration: int.parse(_durationController.text),
        intensity: _selectedIntensity,
        caloriesBurned: _caloriesController.text.isEmpty
            ? null
            : double.tryParse(_caloriesController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        category: _selectedCategory,
        distance: _distanceController.text.isEmpty
            ? null
            : double.tryParse(_distanceController.text),
        heartRate: _heartRateController.text.isEmpty
            ? null
            : int.tryParse(_heartRateController.text),
      );

      // 這裡應該調用數據庫服務保存記錄
      // await DatabaseService().insertExerciseLog(exerciseLog);

      if (mounted) {
        Navigator.pop(context, exerciseLog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingLog != null ? '運動記錄已更新' : '運動記錄已儲存'),
            backgroundColor: AppColors.success,
          ),
        );
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

  String _getCategoryIcon(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.cardio:
        return '❤️';
      case ExerciseCategory.strength:
        return '💪';
      case ExerciseCategory.flexibility:
        return '🤸';
      case ExerciseCategory.sports:
        return '⚽';
      case ExerciseCategory.walking:
        return '🚶';
      case ExerciseCategory.running:
        return '🏃';
      case ExerciseCategory.cycling:
        return '🚴';
      case ExerciseCategory.swimming:
        return '🏊';
      case ExerciseCategory.yoga:
        return '🧘';
      case ExerciseCategory.other:
        return '🏋️';
    }
  }

  String _getCategoryDescription(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.cardio:
        return '有氧';
      case ExerciseCategory.strength:
        return '重訓';
      case ExerciseCategory.flexibility:
        return '柔軟';
      case ExerciseCategory.sports:
        return '球類';
      case ExerciseCategory.walking:
        return '步行';
      case ExerciseCategory.running:
        return '跑步';
      case ExerciseCategory.cycling:
        return '騎行';
      case ExerciseCategory.swimming:
        return '游泳';
      case ExerciseCategory.yoga:
        return '瑜伽';
      case ExerciseCategory.other:
        return '其他';
    }
  }

  IconData _getIntensityIcon(ExerciseIntensity intensity) {
    switch (intensity) {
      case ExerciseIntensity.low:
        return Icons.sentiment_satisfied;
      case ExerciseIntensity.moderate:
        return Icons.sentiment_neutral;
      case ExerciseIntensity.high:
        return Icons.sentiment_dissatisfied;
      case ExerciseIntensity.veryHigh:
        return Icons.whatshot;
    }
  }

  String _getIntensityDescription(ExerciseIntensity intensity) {
    switch (intensity) {
      case ExerciseIntensity.low:
        return '低強度';
      case ExerciseIntensity.moderate:
        return '中強度';
      case ExerciseIntensity.high:
        return '高強度';
      case ExerciseIntensity.veryHigh:
        return '極高強度';
    }
  }

  Color _getIntensityColor(ExerciseIntensity intensity) {
    switch (intensity) {
      case ExerciseIntensity.low:
        return const Color(0xFF4CAF50); // 綠色
      case ExerciseIntensity.moderate:
        return const Color(0xFFFF9800); // 橙色
      case ExerciseIntensity.high:
        return const Color(0xFFF44336); // 紅色
      case ExerciseIntensity.veryHigh:
        return const Color(0xFF9C27B0); // 紫色
    }
  }
}

// 靜態方法用於顯示對話框
class ExerciseLogDialogHelper {
  static Future<ExerciseLog?> showExerciseLogDialog(
      BuildContext context, {
        ExerciseLog? existingLog,
      }) async {
    return await showDialog<ExerciseLog>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExerciseLogDialog(existingLog: existingLog),
    );
  }
}