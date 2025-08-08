class ExerciseLog {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String exerciseType;
  final int duration; // 分鐘
  final ExerciseIntensity intensity;
  final double? caloriesBurned;
  final String? notes;
  final ExerciseCategory category;
  final double? distance; // 公里
  final int? heartRate; // 平均心率

  ExerciseLog({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.exerciseType,
    required this.duration,
    required this.intensity,
    this.caloriesBurned,
    this.notes,
    this.category = ExerciseCategory.other,
    this.distance,
    this.heartRate,
  });

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      exerciseType: map['exerciseType'] ?? '',
      duration: map['duration'] ?? 0,
      intensity: ExerciseIntensity.values[map['intensity'] ?? 0],
      caloriesBurned: map['caloriesBurned']?.toDouble(),
      notes: map['notes'],
      category: ExerciseCategory.values[map['category'] ?? 0],
      distance: map['distance']?.toDouble(),
      heartRate: map['heartRate']?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'exerciseType': exerciseType,
      'duration': duration,
      'intensity': intensity.index,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'category': category.index,
      'distance': distance,
      'heartRate': heartRate,
    };
  }

  // 獲取強度描述
  String get intensityDescription {
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

  // 獲取分類描述
  String get categoryDescription {
    switch (category) {
      case ExerciseCategory.cardio:
        return '有氧運動';
      case ExerciseCategory.strength:
        return '重量訓練';
      case ExerciseCategory.flexibility:
        return '柔軟度訓練';
      case ExerciseCategory.sports:
        return '運動競技';
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

  // 獲取分類圖標
  String get categoryIcon {
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

  // 獲取強度顏色
  String get intensityColor {
    switch (intensity) {
      case ExerciseIntensity.low:
        return '#4CAF50'; // 綠色
      case ExerciseIntensity.moderate:
        return '#FF9800'; // 橙色
      case ExerciseIntensity.high:
        return '#F44336'; // 紅色
      case ExerciseIntensity.veryHigh:
        return '#9C27B0'; // 紫色
    }
  }

  // 計算 MET 值 (代謝當量)
  double get metValue {
    switch (intensity) {
      case ExerciseIntensity.low:
        return 3.0;
      case ExerciseIntensity.moderate:
        return 5.0;
      case ExerciseIntensity.high:
        return 7.0;
      case ExerciseIntensity.veryHigh:
        return 9.0;
    }
  }

  // 估算消耗熱量 (如果沒有提供的話)
  double estimateCaloriesBurned({double bodyWeight = 70.0}) {
    if (caloriesBurned != null) return caloriesBurned!;

    // 使用 MET 公式: 熱量 = MET × 體重(kg) × 時間(小時)
    final hours = duration / 60.0;
    return metValue * bodyWeight * hours;
  }

  // 格式化時間顯示
  String get formattedDuration {
    if (duration < 60) {
      return '${duration}分鐘';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '${hours}小時';
      } else {
        return '${hours}小時${minutes}分鐘';
      }
    }
  }

  // 運動摘要
  String get exerciseSummary {
    List<String> info = [];

    info.add('${exerciseType} (${intensityDescription})');
    info.add('時間: ${formattedDuration}');

    if (distance != null) {
      info.add('距離: ${distance!.toStringAsFixed(1)}公里');
    }

    if (caloriesBurned != null) {
      info.add('熱量: ${caloriesBurned!.toInt()}卡');
    }

    return info.join(' | ');
  }

  // 複製並修改
  ExerciseLog copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? exerciseType,
    int? duration,
    ExerciseIntensity? intensity,
    double? caloriesBurned,
    String? notes,
    ExerciseCategory? category,
    double? distance,
    int? heartRate,
  }) {
    return ExerciseLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      intensity: intensity ?? this.intensity,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      distance: distance ?? this.distance,
      heartRate: heartRate ?? this.heartRate,
    );
  }

  @override
  String toString() {
    return 'ExerciseLog(id: $id, exerciseType: $exerciseType, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ExerciseIntensity {
  low,
  moderate,
  high,
  veryHigh,
}

enum ExerciseCategory {
  cardio,
  strength,
  flexibility,
  sports,
  walking,
  running,
  cycling,
  swimming,
  yoga,
  other,
}