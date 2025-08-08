class GlucoseReading {
  final String id;
  final double value; // mg/dL
  final DateTime timestamp;
  final GlucoseTrend trend;
  final String deviceId;
  final bool isCalibrated;
  final Map<String, dynamic>? metadata;

  GlucoseReading({
    required this.id,
    required this.value,
    required this.timestamp,
    required this.trend,
    required this.deviceId,
    this.isCalibrated = true,
    this.metadata,
  });

  factory GlucoseReading.fromMap(Map<String, dynamic> map) {
    return GlucoseReading(
      id: map['id'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      trend: GlucoseTrend.values[map['trend'] ?? 0],
      deviceId: map['deviceId'] ?? '',
      isCalibrated: map['isCalibrated'] == 1,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'trend': trend.index,
      'deviceId': deviceId,
      'isCalibrated': isCalibrated ? 1 : 0,
      'metadata': metadata?.toString(),
    };
  }

  // 判斷血糖範圍
  GlucoseRange get range {
    if (value < 70) return GlucoseRange.low;
    if (value > 180) return GlucoseRange.high;
    return GlucoseRange.normal;
  }

  // 獲取趨勢箭頭
  String get trendArrow {
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

  // 獲取趨勢描述
  String get trendDescription {
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

  // 獲取範圍描述
  String get rangeDescription {
    switch (range) {
      case GlucoseRange.low:
        return '低血糖';
      case GlucoseRange.high:
        return '高血糖';
      case GlucoseRange.normal:
        return '正常範圍';
    }
  }

  // 複製並修改
  GlucoseReading copyWith({
    String? id,
    double? value,
    DateTime? timestamp,
    GlucoseTrend? trend,
    String? deviceId,
    bool? isCalibrated,
    Map<String, dynamic>? metadata,
  }) {
    return GlucoseReading(
      id: id ?? this.id,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      trend: trend ?? this.trend,
      deviceId: deviceId ?? this.deviceId,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'GlucoseReading(id: $id, value: $value, timestamp: $timestamp, trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlucoseReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum GlucoseTrend {
  rapidlyRising,
  rising,
  stable,
  falling,
  rapidlyFalling,
}

enum GlucoseRange {
  low,
  normal,
  high,
}