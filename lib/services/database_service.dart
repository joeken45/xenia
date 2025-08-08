import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/glucose_reading.dart';
import '../models/food_log.dart';
import '../models/exercise_log.dart';
import '../models/insulin_log.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化數據庫
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 創建表格
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableGlucoseReadings} (
        id TEXT PRIMARY KEY,
        value REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        trend INTEGER NOT NULL,
        deviceId TEXT NOT NULL,
        isCalibrated INTEGER NOT NULL DEFAULT 1,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableFoodLogs} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        foodName TEXT NOT NULL,
        carbohydrates REAL,
        calories REAL,
        category TEXT,
        notes TEXT,
        images TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableExerciseLogs} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        exerciseType TEXT NOT NULL,
        duration INTEGER NOT NULL,
        intensity INTEGER NOT NULL,
        caloriesBurned REAL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableInsulinLogs} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        type INTEGER NOT NULL,
        dose REAL NOT NULL,
        injectionSite INTEGER,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableDeviceInfo} (
        deviceId TEXT PRIMARY KEY,
        serialNumber TEXT NOT NULL,
        firmwareVersion TEXT NOT NULL,
        hardwareVersion TEXT NOT NULL,
        lastConnected INTEGER NOT NULL,
        batteryLevel INTEGER NOT NULL,
        isConnected INTEGER NOT NULL,
        sensorSerialNumber TEXT,
        sensorExpiryDate INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.tableNotifications} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        data TEXT
      )
    ''');

    // 創建索引以提高查詢性能
    await db.execute('''
      CREATE INDEX idx_glucose_timestamp 
      ON ${DatabaseConstants.tableGlucoseReadings} (timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_food_timestamp 
      ON ${DatabaseConstants.tableFoodLogs} (timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_exercise_timestamp 
      ON ${DatabaseConstants.tableExerciseLogs} (timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_insulin_timestamp 
      ON ${DatabaseConstants.tableInsulinLogs} (timestamp DESC)
    ''');
  }

  // 數據庫升級
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 處理數據庫版本升級
    if (oldVersion < 2) {
      // 例如：添加新欄位或表格
    }
  }

  // 初始化服務
  Future<void> initialize() async {
    await database;
    await _cleanOldData();
  }

  // === 血糖讀數相關操作 ===

  // 插入血糖讀數
  Future<void> insertGlucoseReading(GlucoseReading reading) async {
    final db = await database;
    await db.insert(
      DatabaseConstants.tableGlucoseReadings,
      reading.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量插入血糖讀數
  Future<void> insertGlucoseReadings(List<GlucoseReading> readings) async {
    final db = await database;
    final batch = db.batch();

    for (final reading in readings) {
      batch.insert(
        DatabaseConstants.tableGlucoseReadings,
        reading.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  // 獲取血糖讀數
  Future<List<GlucoseReading>> getGlucoseReadings({
    int? limit,
    int? hours,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (hours != null) {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      whereClause = 'timestamp >= ?';
      whereArgs.add(cutoffTime.millisecondsSinceEpoch);
    } else if (startTime != null && endTime != null) {
      whereClause = 'timestamp BETWEEN ? AND ?';
      whereArgs.addAll([
        startTime.millisecondsSinceEpoch,
        endTime.millisecondsSinceEpoch,
      ]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableGlucoseReadings,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return GlucoseReading.fromMap(maps[i]);
    });
  }

  // 獲取最新血糖讀數
  Future<GlucoseReading?> getLatestGlucoseReading() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableGlucoseReadings,
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return GlucoseReading.fromMap(maps.first);
    }
    return null;
  }

  // === 飲食紀錄相關操作 ===

  // 插入飲食紀錄
  Future<void> insertFoodLog(FoodLog foodLog) async {
    final db = await database;
    final map = foodLog.toMap();
    // 將圖片列表轉換為 JSON 字符串
    if (foodLog.images != null) {
      map['images'] = foodLog.images!.join(',');
    }

    await db.insert(
      DatabaseConstants.tableFoodLogs,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 獲取飲食紀錄
  Future<List<FoodLog>> getFoodLogs({
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startTime != null && endTime != null) {
      whereClause = 'timestamp BETWEEN ? AND ?';
      whereArgs.addAll([
        startTime.millisecondsSinceEpoch,
        endTime.millisecondsSinceEpoch,
      ]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableFoodLogs,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 將圖片字符串轉換回列表
      if (map['images'] != null && map['images'].isNotEmpty) {
        map['images'] = (map['images'] as String).split(',');
      }
      return FoodLog.fromMap(map);
    });
  }

  // 刪除飲食紀錄
  Future<void> deleteFoodLog(String id) async {
    final db = await database;
    await db.delete(
      DatabaseConstants.tableFoodLogs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === 運動紀錄相關操作 ===

  // 插入運動紀錄
  Future<void> insertExerciseLog(ExerciseLog exerciseLog) async {
    final db = await database;
    await db.insert(
      DatabaseConstants.tableExerciseLogs,
      exerciseLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 獲取運動紀錄
  Future<List<ExerciseLog>> getExerciseLogs({
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startTime != null && endTime != null) {
      whereClause = 'timestamp BETWEEN ? AND ?';
      whereArgs.addAll([
        startTime.millisecondsSinceEpoch,
        endTime.millisecondsSinceEpoch,
      ]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableExerciseLogs,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ExerciseLog.fromMap(maps[i]);
    });
  }

  // 刪除運動紀錄
  Future<void> deleteExerciseLog(String id) async {
    final db = await database;
    await db.delete(
      DatabaseConstants.tableExerciseLogs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === 胰島素紀錄相關操作 ===

  // 插入胰島素紀錄
  Future<void> insertInsulinLog(InsulinLog insulinLog) async {
    final db = await database;
    await db.insert(
      DatabaseConstants.tableInsulinLogs,
      insulinLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 獲取胰島素紀錄
  Future<List<InsulinLog>> getInsulinLogs({
    int? limit,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startTime != null && endTime != null) {
      whereClause = 'timestamp BETWEEN ? AND ?';
      whereArgs.addAll([
        startTime.millisecondsSinceEpoch,
        endTime.millisecondsSinceEpoch,
      ]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.tableInsulinLogs,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return InsulinLog.fromMap(maps[i]);
    });
  }

  // 刪除胰島素紀錄
  Future<void> deleteInsulinLog(String id) async {
    final db = await database;
    await db.delete(
      DatabaseConstants.tableInsulinLogs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === 通用操作 ===

  // 清理舊數據
  Future<void> _cleanOldData() async {
    final db = await database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: DatabaseConstants.dataRetentionDays));

    await db.delete(
      DatabaseConstants.tableGlucoseReadings,
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch],
    );
  }

  // 清除所有數據
  Future<void> clearAllData() async {
    final db = await database;
    final batch = db.batch();

    batch.delete(DatabaseConstants.tableGlucoseReadings);
    batch.delete(DatabaseConstants.tableFoodLogs);
    batch.delete(DatabaseConstants.tableExerciseLogs);
    batch.delete(DatabaseConstants.tableInsulinLogs);
    batch.delete(DatabaseConstants.tableNotifications);

    await batch.commit();
  }

  // 獲取數據庫大小
  Future<int> getDatabaseSize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);
    final file = File(path);

    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // 關閉數據庫
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}