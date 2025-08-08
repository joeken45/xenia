import 'constants.dart';

class Validators {
  // Email 驗證
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入電子信箱';
    }

    final emailRegExp = RegExp(ValidationRules.emailPattern);
    if (!emailRegExp.hasMatch(value)) {
      return '請輸入有效的電子信箱格式';
    }

    return null;
  }

  // 密碼驗證
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入密碼';
    }

    if (value.length < ValidationRules.passwordMinLength) {
      return '密碼至少需要 ${ValidationRules.passwordMinLength} 個字符';
    }

    if (value.length > ValidationRules.passwordMaxLength) {
      return '密碼最多 ${ValidationRules.passwordMaxLength} 個字符';
    }

    // 檢查是否包含數字
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return '密碼必須包含至少一個數字';
    }

    // 檢查是否包含字母
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return '密碼必須包含至少一個字母';
    }

    return null;
  }

  // 確認密碼驗證
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return '請確認密碼';
    }

    if (value != password) {
      return '兩次輸入的密碼不一致';
    }

    return null;
  }

  // 姓名驗證
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入姓名';
    }

    if (value.trim().length < 2) {
      return '姓名至少需要 2 個字符';
    }

    if (value.trim().length > 50) {
      return '姓名最多 50 個字符';
    }

    return null;
  }

  // 手機號碼驗證 (台灣)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 手機號碼為選填
    }

    final phoneRegExp = RegExp(ValidationRules.phonePattern);
    if (!phoneRegExp.hasMatch(value)) {
      return '請輸入有效的手機號碼格式 (09xxxxxxxx)';
    }

    return null;
  }

  // 血糖值驗證
  static String? validateGlucoseValue(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入血糖值';
    }

    final glucoseValue = double.tryParse(value);
    if (glucoseValue == null) {
      return '請輸入有效的血糖值';
    }

    if (glucoseValue < ValidationRules.glucoseMinValue) {
      return '血糖值不能低於 ${ValidationRules.glucoseMinValue} mg/dL';
    }

    if (glucoseValue > ValidationRules.glucoseMaxValue) {
      return '血糖值不能高於 ${ValidationRules.glucoseMaxValue} mg/dL';
    }

    return null;
  }

  // 胰島素劑量驗證
  static String? validateInsulinDose(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入胰島素劑量';
    }

    final dose = double.tryParse(value);
    if (dose == null) {
      return '請輸入有效的劑量';
    }

    if (dose < ValidationRules.insulinMinDose) {
      return '胰島素劑量不能低於 ${ValidationRules.insulinMinDose} 單位';
    }

    if (dose > ValidationRules.insulinMaxDose) {
      return '胰島素劑量不能高於 ${ValidationRules.insulinMaxDose} 單位';
    }

    return null;
  }

  // 碳水化合物驗證
  static String? validateCarbohydrates(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 碳水化合物為選填
    }

    final carbs = double.tryParse(value);
    if (carbs == null) {
      return '請輸入有效的碳水化合物量';
    }

    if (carbs < ValidationRules.carbsMinValue) {
      return '碳水化合物量不能為負數';
    }

    if (carbs > ValidationRules.carbsMaxValue) {
      return '碳水化合物量不能超過 ${ValidationRules.carbsMaxValue} 公克';
    }

    return null;
  }

  // 熱量驗證
  static String? validateCalories(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 熱量為選填
    }

    final calories = double.tryParse(value);
    if (calories == null) {
      return '請輸入有效的熱量值';
    }

    if (calories < 0) {
      return '熱量不能為負數';
    }

    if (calories > 10000) {
      return '熱量值過大';
    }

    return null;
  }

  // 運動時間驗證
  static String? validateExerciseDuration(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入運動時間';
    }

    final duration = int.tryParse(value);
    if (duration == null) {
      return '請輸入有效的時間（分鐘）';
    }

    if (duration <= 0) {
      return '運動時間必須大於 0 分鐘';
    }

    if (duration > 480) { // 8小時
      return '運動時間不能超過 480 分鐘';
    }

    return null;
  }

  // 食物名稱驗證
  static String? validateFoodName(String? value) {
    if (value == null || value.isEmpty) {
      return '請輸入食物名稱';
    }

    if (value.trim().length < 1) {
      return '食物名稱不能為空';
    }

    if (value.trim().length > 100) {
      return '食物名稱最多 100 個字符';
    }

    return null;
  }

  // 運動類型驗證
  static String? validateExerciseType(String? value) {
    if (value == null || value.isEmpty) {
      return '請選擇或輸入運動類型';
    }

    if (value.trim().length < 1) {
      return '運動類型不能為空';
    }

    if (value.trim().length > 50) {
      return '運動類型最多 50 個字符';
    }

    return null;
  }

  // 備註驗證
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 備註為選填
    }

    if (value.trim().length > 500) {
      return '備註最多 500 個字符';
    }

    return null;
  }

  // 門檻值驗證
  static String? validateThreshold(String? value, double minValue, double maxValue) {
    if (value == null || value.isEmpty) {
      return '請輸入門檻值';
    }

    final threshold = double.tryParse(value);
    if (threshold == null) {
      return '請輸入有效的數值';
    }

    if (threshold < minValue) {
      return '門檻值不能低於 $minValue';
    }

    if (threshold > maxValue) {
      return '門檻值不能高於 $maxValue';
    }

    return null;
  }

  // 高血糖門檻驗證
  static String? validateHighThreshold(String? value, {double? lowThreshold}) {
    final error = validateThreshold(value, 100, 400);
    if (error != null) return error;

    if (lowThreshold != null) {
      final highValue = double.tryParse(value!);
      if (highValue != null && highValue <= lowThreshold) {
        return '高血糖門檻必須大於低血糖門檻';
      }
    }

    return null;
  }

  // 低血糖門檻驗證
  static String? validateLowThreshold(String? value, {double? highThreshold}) {
    final error = validateThreshold(value, 40, 150);
    if (error != null) return error;

    if (highThreshold != null) {
      final lowValue = double.tryParse(value!);
      if (lowValue != null && lowValue >= highThreshold) {
        return '低血糖門檻必須小於高血糖門檻';
      }
    }

    return null;
  }

  // 通用非空驗證
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '請輸入$fieldName';
    }
    return null;
  }

  // 數字範圍驗證
  static String? validateNumberRange(
      String? value,
      String fieldName,
      double min,
      double max,
      ) {
    if (value == null || value.isEmpty) {
      return '請輸入$fieldName';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '請輸入有效的$fieldName';
    }

    if (number < min || number > max) {
      return '$fieldName 必須在 $min 到 $max 之間';
    }

    return null;
  }

  // 整數範圍驗證
  static String? validateIntRange(
      String? value,
      String fieldName,
      int min,
      int max,
      ) {
    if (value == null || value.isEmpty) {
      return '請輸入$fieldName';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '請輸入有效的$fieldName';
    }

    if (number < min || number > max) {
      return '$fieldName 必須在 $min 到 $max 之間';
    }

    return null;
  }

  // 組合驗證器
  static String? Function(String?) combineValidators(
      List<String? Function(String?)> validators,
      ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  // 條件驗證器
  static String? Function(String?) conditionalValidator(
      bool Function() condition,
      String? Function(String?) validator,
      ) {
    return (String? value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }
}