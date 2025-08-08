class DeviceInfo {
  final String deviceId;
  final String serialNumber;
  final String firmwareVersion;
  final String hardwareVersion;
  final DateTime lastConnected;
  final int batteryLevel;
  final bool isConnected;
  final String? sensorSerialNumber;
  final DateTime? sensorExpiryDate;
  final DeviceType deviceType;
  final String? manufacturerName;

  DeviceInfo({
    required this.deviceId,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.hardwareVersion,
    required this.lastConnected,
    required this.batteryLevel,
    required this.isConnected,
    this.sensorSerialNumber,
    this.sensorExpiryDate,
    this.deviceType = DeviceType.cgm,
    this.manufacturerName,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceId: map['deviceId'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      firmwareVersion: map['firmwareVersion'] ?? '',
      hardwareVersion: map['hardwareVersion'] ?? '',
      lastConnected: DateTime.fromMillisecondsSinceEpoch(map['lastConnected'] ?? 0),
      batteryLevel: map['batteryLevel'] ?? 0,
      isConnected: map['isConnected'] == 1,
      sensorSerialNumber: map['sensorSerialNumber'],
      sensorExpiryDate: map['sensorExpiryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sensorExpiryDate'])
          : null,
      deviceType: DeviceType.values[map['deviceType'] ?? 0],
      manufacturerName: map['manufacturerName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'serialNumber': serialNumber,
      'firmwareVersion': firmwareVersion,
      'hardwareVersion': hardwareVersion,
      'lastConnected': lastConnected.millisecondsSinceEpoch,
      'batteryLevel': batteryLevel,
      'isConnected': isConnected ? 1 : 0,
      'sensorSerialNumber': sensorSerialNumber,
      'sensorExpiryDate': sensorExpiryDate?.millisecondsSinceEpoch,
      'deviceType': deviceType.index,
      'manufacturerName': manufacturerName,
    };
  }

  // 獲取電池狀態
  BatteryStatus get batteryStatus {
    if (batteryLevel >= 80) return BatteryStatus.excellent;
    if (batteryLevel >= 60) return BatteryStatus.good;
    if (batteryLevel >= 30) return BatteryStatus.fair;
    if (batteryLevel >= 15) return BatteryStatus.low;
    return BatteryStatus.critical;
  }

  // 獲取電池狀態描述
  String get batteryStatusDescription {
    switch (batteryStatus) {
      case BatteryStatus.excellent:
        return '電量充足';
      case BatteryStatus.good:
        return '電量良好';
      case BatteryStatus.fair:
        return '電量普通';
      case BatteryStatus.low:
        return '電量不足';
      case BatteryStatus.critical:
        return '電量嚴重不足';
    }
  }

  // 檢查感測器是否即將過期
  bool get isSensorExpiringSoon {
    if (sensorExpiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = sensorExpiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 2; // 2天內過期
  }

  // 獲取感測器剩餘天數
  int get sensorRemainingDays {
    if (sensorExpiryDate == null) return -1;
    final now = DateTime.now();
    return sensorExpiryDate!.difference(now).inDays;
  }

  // 獲取連接狀態描述
  String get connectionStatusDescription {
    return isConnected ? '已連接' : '未連接';
  }

  // 獲取設備類型描述
  String get deviceTypeDescription {
    switch (deviceType) {
      case DeviceType.cgm:
        return '連續血糖監測器';
      case DeviceType.glucometer:
        return '血糖機';
      case DeviceType.insulinPump:
        return '胰島素幫浦';
      case DeviceType.other:
        return '其他設備';
    }
  }

  // 複製並修改
  DeviceInfo copyWith({
    String? deviceId,
    String? serialNumber,
    String? firmwareVersion,
    String? hardwareVersion,
    DateTime? lastConnected,
    int? batteryLevel,
    bool? isConnected,
    String? sensorSerialNumber,
    DateTime? sensorExpiryDate,
    DeviceType? deviceType,
    String? manufacturerName,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      serialNumber: serialNumber ?? this.serialNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
      lastConnected: lastConnected ?? this.lastConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isConnected: isConnected ?? this.isConnected,
      sensorSerialNumber: sensorSerialNumber ?? this.sensorSerialNumber,
      sensorExpiryDate: sensorExpiryDate ?? this.sensorExpiryDate,
      deviceType: deviceType ?? this.deviceType,
      manufacturerName: manufacturerName ?? this.manufacturerName,
    );
  }

  @override
  String toString() {
    return 'DeviceInfo(deviceId: $deviceId, serialNumber: $serialNumber, isConnected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}

enum DeviceType {
  cgm,
  glucometer,
  insulinPump,
  other,
}

enum BatteryStatus {
  excellent,
  good,
  fair,
  low,
  critical,
}