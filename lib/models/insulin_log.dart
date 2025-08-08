class InsulinLog {
  final String id;
  final String userId;
  final DateTime timestamp;
  final InsulinType type;
  final double dose; // 單位
  final InjectionSite? injectionSite;
  final String? notes;
  final String? brandName;
  final InsulinPurpose purpose;

  InsulinLog({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.dose,
    this.injectionSite,
    this.notes,
    this.brandName,
    this.purpose = InsulinPurpose.mealtime,
  });

  factory InsulinLog.fromMap(Map<String, dynamic> map) {
    return InsulinLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      type: InsulinType.values[map['type'] ?? 0],
      dose: (map['dose'] ?? 0.0).toDouble(),
      injectionSite: map['injectionSite'] != null
          ? InjectionSite.values[map['injectionSite']]
          : null,
      notes: map['notes'],
      brandName: map['brandName'],
      purpose: InsulinPurpose.values[map['purpose'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'dose': dose,
      'injectionSite': injectionSite?.index,
      'notes': notes,
      'brandName': brandName,
      'purpose': purpose.index,
    };
  }

  // 獲取胰島素類型描述
  String get typeDescription {
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

  // 獲取注射部位描述
  String get injectionSiteDescription {
    if (injectionSite == null) return '未記錄';
    switch (injectionSite!) {
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

  // 獲取用途描述
  String get purposeDescription {
    switch (purpose) {
      case InsulinPurpose.mealtime:
        return '餐前用藥';
      case InsulinPurpose.correction:
        return '校正用藥';
      case InsulinPurpose.basal:
        return '基礎用藥';
      case InsulinPurpose.bedtime:
        return '睡前用藥';
    }
  }

  // 獲取作用時間資訊
  InsulinActionProfile get actionProfile {
    switch (type) {
      case InsulinType.rapidActing:
        return InsulinActionProfile(
          onset: 15, // 15分鐘
          peak: 60,  // 1小時
          duration: 240, // 4小時
        );
      case InsulinType.shortActing:
        return InsulinActionProfile(
          onset: 30, // 30分鐘
          peak: 120, // 2小時
          duration: 360, // 6小時
        );
      case InsulinType.intermediate:
        return InsulinActionProfile(
          onset: 120, // 2小時
          peak: 480,  // 8小時
          duration: 1440, // 24小時
        );
      case InsulinType.longActing:
        return InsulinActionProfile(
          onset: 120, // 2小時
          peak: null, // 無明顯峰值
          duration: 1440, // 24小時+
        );
      case InsulinType.premixed:
        return InsulinActionProfile(
          onset: 30, // 30分鐘
          peak: 180, // 3小時
          duration: 720, // 12小時
        );
    }
  }

  // 獲取胰島素圖標
  String get typeIcon {
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

  // 獲取用途圖標
  String get purposeIcon {
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

  // 判斷是否為高劑量
  bool get isHighDose {
    switch (type) {
      case InsulinType.rapidActing:
      case InsulinType.shortActing:
        return dose > 15; // 速效/短效超過15單位
      case InsulinType.intermediate:
      case InsulinType.longActing:
      case InsulinType.premixed:
        return dose > 30; // 中效/長效/預混超過30單位
    }
  }

  // 獲取劑量等級
  DoseLevel get doseLevel {
    if (dose <= 5) return DoseLevel.low;
    if (dose <= 15) return DoseLevel.moderate;
    if (dose <= 30) return DoseLevel.high;
    return DoseLevel.veryHigh;
  }

  // 獲取劑量等級描述
  String get doseLevelDescription {
    switch (doseLevel) {
      case DoseLevel.low:
        return '低劑量';
      case DoseLevel.moderate:
        return '中等劑量';
      case DoseLevel.high:
        return '高劑量';
      case DoseLevel.veryHigh:
        return '極高劑量';
    }
  }

  // 格式化劑量顯示
  String get formattedDose {
    if (dose == dose.toInt()) {
      return '${dose.toInt()}單位';
    } else {
      return '${dose.toStringAsFixed(1)}單位';
    }
  }

  // 胰島素摘要
  String get insulinSummary {
    List<String> info = [];

    info.add('${typeDescription} ${formattedDose}');
    info.add(purposeDescription);

    if (injectionSite != null) {
      info.add(injectionSiteDescription);
    }

    if (brandName != null && brandName!.isNotEmpty) {
      info.add(brandName!);
    }

    return info.join(' | ');
  }

  // 預計作用時間文字
  String get expectedActionText {
    final profile = actionProfile;
    String text = '預計${profile.onset}分鐘後開始作用';

    if (profile.peak != null) {
      final peakHours = profile.peak! / 60;
      if (peakHours >= 1) {
        text += '，${peakHours.toInt()}小時後達到高峰';
      } else {
        text += '，${profile.peak}分鐘後達到高峰';
      }
    }

    final durationHours = profile.duration / 60;
    text += '，持續約${durationHours.toInt()}小時';

    return text;
  }

  // 複製並修改
  InsulinLog copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    InsulinType? type,
    double? dose,
    InjectionSite? injectionSite,
    String? notes,
    String? brandName,
    InsulinPurpose? purpose,
  }) {
    return InsulinLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      dose: dose ?? this.dose,
      injectionSite: injectionSite ?? this.injectionSite,
      notes: notes ?? this.notes,
      brandName: brandName ?? this.brandName,
      purpose: purpose ?? this.purpose,
    );
  }

  @override
  String toString() {
    return 'InsulinLog(id: $id, type: $type, dose: $dose)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InsulinLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum InsulinType {
  rapidActing,  // 速效
  shortActing,  // 短效
  intermediate, // 中效
  longActing,   // 長效
  premixed,     // 預混
}

enum InjectionSite {
  abdomen,    // 腹部
  thigh,      // 大腿
  arm,        // 手臂
  buttocks,   // 臀部
}

enum InsulinPurpose {
  mealtime,   // 餐前
  correction, // 校正
  basal,      // 基礎
  bedtime,    // 睡前
}

enum DoseLevel {
  low,
  moderate,
  high,
  veryHigh,
}

class InsulinActionProfile {
  final int onset;      // 起效時間（分鐘）
  final int? peak;      // 峰值時間（分鐘）
  final int duration;   // 持續時間（分鐘）

  InsulinActionProfile({
    required this.onset,
    this.peak,
    required this.duration,
  });
}