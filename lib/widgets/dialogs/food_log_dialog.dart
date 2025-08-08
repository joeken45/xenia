import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../models/food_log.dart';

class FoodLogDialog extends StatefulWidget {
  final FoodLog? existingLog;

  const FoodLogDialog({
    super.key,
    this.existingLog,
  });

  @override
  State<FoodLogDialog> createState() => _FoodLogDialogState();
}

class _FoodLogDialogState extends State<FoodLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _carbsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  MealType _selectedMealType = MealType.other;
  String _selectedUnit = '份';
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  final List<String> _units = ['份', '克', '毫升', '個', '片', '杯'];

  final List<String> _commonFoods = [
    '白米飯', '麵條', '麵包', '蘋果', '香蕉', '牛奶', '雞蛋', '雞肉',
    '豬肉', '魚肉', '蔬菜', '豆腐', '優格', '堅果', '餅乾', '蛋糕'
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
    _foodNameController.text = log.foodName;
    _carbsController.text = log.carbohydrates?.toString() ?? '';
    _caloriesController.text = log.calories?.toString() ?? '';
    _quantityController.text = log.quantity?.toString() ?? '';
    _notesController.text = log.notes ?? '';
    _selectedMealType = log.mealType;
    _selectedUnit = log.unit ?? '份';
    _selectedDateTime = log.timestamp;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _carbsController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSizes.paddingM),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
                      _buildFoodNameField(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildMealTypeSelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildQuantityFields(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildNutritionFields(),
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
            Icons.restaurant,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              widget.existingLog != null ? '編輯飲食記錄' : '新增飲食記錄',
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

  Widget _buildFoodNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _foodNameController,
          labelText: '食物名稱',
          hintText: '請輸入食物名稱',
          prefixIcon: Icons.fastfood,
          validator: Validators.validateFoodName,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonFoods.map((food) {
            return InkWell(
              onTap: () {
                _foodNameController.text = food;
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
                  food,
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

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '餐次',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Row(
            children: MealType.values.map((type) {
              final isSelected = type == _selectedMealType;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealType = type;
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
                          _getMealTypeIcon(type),
                          style: TextStyle(
                            fontSize: 20,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMealTypeDescription(type),
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

  Widget _buildQuantityFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: NumberTextField(
            controller: _quantityController,
            labelText: '數量',
            hintText: '0',
            decimalPlaces: 1,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedUnit,
            decoration: const InputDecoration(
              labelText: '單位',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusL)),
                borderSide: BorderSide.none,
              ),
            ),
            items: _units.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedUnit = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '營養資訊（選填）',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Row(
          children: [
            Expanded(
              child: NumberTextField(
                controller: _carbsController,
                labelText: '碳水化合物',
                hintText: '0',
                suffix: 'g',
                decimalPlaces: 1,
                validator: Validators.validateCarbohydrates,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: NumberTextField(
                controller: _caloriesController,
                labelText: '熱量',
                hintText: '0',
                suffix: 'kcal',
                decimalPlaces: 0,
                validator: Validators.validateCalories,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '用餐時間',
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
              onPressed: _isLoading ? null : _saveFoodLog,
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

  Future<void> _saveFoodLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final foodLog = FoodLog(
        id: widget.existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // 應該從認證狀態獲取
        timestamp: _selectedDateTime,
        foodName: _foodNameController.text.trim(),
        carbohydrates: _carbsController.text.isEmpty
            ? null
            : double.tryParse(_carbsController.text),
        calories: _caloriesController.text.isEmpty
            ? null
            : double.tryParse(_caloriesController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        mealType: _selectedMealType,
        quantity: _quantityController.text.isEmpty
            ? null
            : double.tryParse(_quantityController.text),
        unit: _selectedUnit,
      );

      // 這裡應該調用數據庫服務保存記錄
      // await DatabaseService().insertFoodLog(foodLog);

      if (mounted) {
        Navigator.pop(context, foodLog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingLog != null ? '飲食記錄已更新' : '飲食記錄已儲存'),
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

  String _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍪';
      case MealType.other:
        return '🍽️';
    }
  }

  String _getMealTypeDescription(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '早餐';
      case MealType.lunch:
        return '午餐';
      case MealType.dinner:
        return '晚餐';
      case MealType.snack:
        return '點心';
      case MealType.other:
        return '其他';
    }
  }
}

// 靜態方法用於顯示對話框
class FoodLogDialogHelper {
  static Future<FoodLog?> showFoodLogDialog(
      BuildContext context, {
        FoodLog? existingLog,
      }) async {
    return await showDialog<FoodLog>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FoodLogDialog(existingLog: existingLog),
    );
  }
}