class FoodLog {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String foodName;
  final double? carbohydrates; // 克
  final double? calories;
  final String? category;
  final String? notes;
  final List<String>? images;
  final MealType mealType;
  final double? quantity;
  final String? unit;

  FoodLog({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.foodName,
    this.carbohydrates,
    this.calories,
    this.category,
    this.notes,
    this.images,
    this.mealType = MealType.other,
    this.quantity,
    this.unit,
  });

  factory FoodLog.fromMap(Map<String, dynamic> map) {
    return FoodLog(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      foodName: map['foodName'] ?? '',
      carbohydrates: map['carbohydrates']?.toDouble(),
      calories: map['calories']?.toDouble(),
      category: map['category'],
      notes: map['notes'],
      images: map['images'] != null
          ? List<String>.from(map['images'].split(',').where((s) => s.isNotEmpty))
          : null,
      mealType: MealType.values[map['mealType'] ?? 0],
      quantity: map['quantity']?.toDouble(),
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'foodName': foodName,
      'carbohydrates': carbohydrates,
      'calories': calories,
      'category': category,
      'notes': notes,
      'images': images?.join(','),
      'mealType': mealType.index,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // 獲取餐次描述
  String get mealTypeDescription {
    switch (mealType) {
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

  // 獲取餐次圖標
  String get mealTypeIcon {
    switch (mealType) {
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

  // 判斷是否為高碳水食物
  bool get isHighCarb {
    if (carbohydrates == null) return false;
    return carbohydrates! > 30; // 大於30g為高碳水
  }

  // 獲取碳水化合物等級
  CarbLevel get carbLevel {
    if (carbohydrates == null) return CarbLevel.unknown;
    if (carbohydrates! <= 15) return CarbLevel.low;
    if (carbohydrates! <= 30) return CarbLevel.moderate;
    return CarbLevel.high;
  }

  // 獲取碳水化合物等級描述
  String get carbLevelDescription {
    switch (carbLevel) {
      case CarbLevel.low:
        return '低碳水';
      case CarbLevel.moderate:
        return '中碳水';
      case CarbLevel.high:
        return '高碳水';
      case CarbLevel.unknown:
        return '未知';
    }
  }

  // 格式化顯示文字
  String get displayText {
    String text = foodName;
    if (quantity != null && unit != null) {
      text += ' (${quantity}${unit})';
    }
    return text;
  }

  // 獲取營養資訊摘要
  String get nutritionSummary {
    List<String> info = [];

    if (carbohydrates != null) {
      info.add('碳水: ${carbohydrates!.toStringAsFixed(1)}g');
    }

    if (calories != null) {
      info.add('熱量: ${calories!.toInt()}kcal');
    }

    return info.join(' | ');
  }

  // 複製並修改
  FoodLog copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? foodName,
    double? carbohydrates,
    double? calories,
    String? category,
    String? notes,
    List<String>? images,
    MealType? mealType,
    double? quantity,
    String? unit,
  }) {
    return FoodLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      foodName: foodName ?? this.foodName,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      mealType: mealType ?? this.mealType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() {
    return 'FoodLog(id: $id, foodName: $foodName, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  other,
}

enum CarbLevel {
  low,
  moderate,
  high,
  unknown,
}