import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../models/insulin_log.dart';

class InsulinLogDialog extends StatefulWidget {
  final InsulinLog? existingLog;

  const InsulinLogDialog({
    super.key,
    this.existingLog,
  });

  @override
  State<InsulinLogDialog> createState() => _InsulinLogDialogState();
}

class _InsulinLogDialogState extends State<InsulinLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _doseController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _notesController = TextEditingController();

  InsulinType _selectedType = InsulinType.rapidActing;
  InjectionSite? _selectedSite;
  InsulinPurpose _selectedPurpose = InsulinPurpose.mealtime;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  final List<String> _commonBrands = [
    'Humalog', 'NovoRapid', 'Apidra', 'Lantus', 'Levemir',
    'Tresiba', 'Humulin', 'Novolin', 'Fiasp', 'Toujeo'
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
    _doseController.text = log.dose.toString();
    _brandNameController.text = log.brandName ?? '';
    _notesController.text = log.notes ?? '';
    _selectedType = log.type;
    _selectedSite = log.injectionSite;
    _selectedPurpose = log.purpose;
    _selectedDateTime = log.timestamp;
  }

  @override
  void dispose() {
    _doseController.dispose();
    _brandNameController.dispose();
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
                      _buildInsulinTypeSelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildDoseField(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildPurposeSelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildInjectionSiteSelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildBrandNameField(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildDateTimeSelector(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildNotesField(),
                      const SizedBox(height: AppSizes.paddingM),
                      _buildActionProfile(),
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
            Icons.medication,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Text(
              widget.existingLog != null ? '編輯胰島素記錄' : '新增胰島素記錄',
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

  Widget _buildInsulinTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '胰島素類型',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: InsulinType.values.map((type) {
            final isSelected = type == _selectedType;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      _getTypeIcon(type),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTypeDescription(type),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildDoseField() {
    return NumberTextField(
      controller: _doseController,
      labelText: '劑量',
      hintText: '0',
      suffix: '單位',
      decimalPlaces: 1,
      validator: Validators.validateInsulinDose,
    );
  }

  Widget _buildPurposeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '用藥目的',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Row(
            children: InsulinPurpose.values.map((purpose) {
              final isSelected = purpose == _selectedPurpose;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPurpose = purpose;
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
                          _getPurposeIcon(purpose),
                          style: TextStyle(
                            fontSize: 20,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPurposeDescription(purpose),
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

  Widget _buildInjectionSiteSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注射部位',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSiteOption(null, '未記錄', Icons.help_outline),
            ...InjectionSite.values.map((site) {
              return _buildSiteOption(site, _getSiteDescription(site), _getSiteIcon(site));
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildSiteOption(InjectionSite? site, String label, IconData icon) {
    final isSelected = site == _selectedSite;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSite = site;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _brandNameController,
          labelText: '品牌名稱（選填）',
          hintText: '請輸入胰島素品牌',
          prefixIcon: Icons.local_pharmacy,
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonBrands.map((brand) {
            return InkWell(
              onTap: () {
                _brandNameController.text = brand;
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
                  brand,
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

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注射時間',
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

  Widget _buildActionProfile() {
    final profile = _getActionProfile(_selectedType);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                '作用時間',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            _getActionDescription(profile),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
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
              onPressed: _isLoading ? null : _saveInsulinLog,
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

  Future<void> _saveInsulinLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final insulinLog = InsulinLog(
        id: widget.existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // 應該從認證狀態獲取
        timestamp: _selectedDateTime,
        type: _selectedType,
        dose: double.parse(_doseController.text),
        injectionSite: _selectedSite,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        brandName: _brandNameController.text.trim().isEmpty
            ? null
            : _brandNameController.text.trim(),
        purpose: _selectedPurpose,
      );

      // 這裡應該調用數據庫服務保存記錄
      // await DatabaseService().insertInsulinLog(insulinLog);

      if (mounted) {
        Navigator.pop(context, insulinLog);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingLog != null ? '胰島素記錄已更新' : '胰島素記錄已儲存'),
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

  String _getTypeIcon(InsulinType type) {
    switch (type) {
      case InsulinType.rapidActing:
        return '⚡';
      case InsulinType.shortActing:
        return '🏃';
      case InsulinType.intermediate:
        return '⏰';
      case InsulinType.longActing:
        return '🔋';
      case InsulinType.premixed:
        return '🔄';
    }
  }

  String _getTypeDescription(InsulinType type) {
    switch (type) {
      case InsulinType.rapidActing:
        return '速效胰島素';
      case InsulinType.shortActing:
        return '短效胰島素';
      case InsulinType.intermediate:
        return '中效胰島素';
      case InsulinType.longActing:
        return '長效胰島素';
      case InsulinType.premixed:
        return '預混胰島素';
    }
  }

  String _getPurposeIcon(InsulinPurpose purpose) {
    switch (purpose) {
      case InsulinPurpose.mealtime:
        return '🍽️';
      case InsulinPurpose.correction:
        return '🎯';
      case InsulinPurpose.basal:
        return '⚖️';
      case InsulinPurpose.bedtime:
        return '🛏️';
    }
  }

  String _getPurposeDescription(InsulinPurpose purpose) {
    switch (purpose) {
      case InsulinPurpose.mealtime:
        return '餐前';
      case InsulinPurpose.correction:
        return '校正';
      case InsulinPurpose.basal:
        return '基礎';
      case InsulinPurpose.bedtime:
        return '睡前';
    }
  }

  IconData _getSiteIcon(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return Icons.accessibility_new;
      case InjectionSite.thigh:
        return Icons.directions_walk;
      case InjectionSite.arm:
        return Icons.back_hand;
      case InjectionSite.buttocks:
        return Icons.airline_seat_recline_normal;
    }
  }

  String _getSiteDescription(InjectionSite site) {
    switch (site) {
      case InjectionSite.abdomen:
        return '腹部';
      case InjectionSite.thigh:
        return '大腿';
      case InjectionSite.arm:
        return '手臂';
      case InjectionSite.buttocks:
        return '臀部';
    }
  }

  InsulinActionProfile _getActionProfile(InsulinType type) {
    switch (type) {
      case InsulinType.rapidActing:
        return InsulinActionProfile(onset: 15, peak: 60, duration: 240);
      case InsulinType.shortActing:
        return InsulinActionProfile(onset: 30, peak: 120, duration: 360);
      case InsulinType.intermediate:
        return InsulinActionProfile(onset: 120, peak: 480, duration: 1440);
      case InsulinType.longActing:
        return InsulinActionProfile(onset: 120, peak: null, duration: 1440);
      case InsulinType.premixed:
        return InsulinActionProfile(onset: 30, peak: 180, duration: 720);
    }
  }

  String _getActionDescription(InsulinActionProfile profile) {
    String text = '起效時間: ${profile.onset}分鐘';

    if (profile.peak != null) {
      final peakHours = profile.peak! / 60;
      if (peakHours >= 1) {
        text += '，高峰: ${peakHours.toInt()}小時';
      } else {
        text += '，高峰: ${profile.peak}分鐘';
      }
    } else {
      text += '，無明顯高峰';
    }

    final durationHours = profile.duration / 60;
    text += '，持續: ${durationHours.toInt()}小時';

    return text;
  }
}

// 靜態方法用於顯示對話框
class InsulinLogDialogHelper {
  static Future<InsulinLog?> showInsulinLogDialog(
      BuildContext context, {
        InsulinLog? existingLog,
      }) async {
    return await showDialog<InsulinLog>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InsulinLogDialog(existingLog: existingLog),
    );
  }
}