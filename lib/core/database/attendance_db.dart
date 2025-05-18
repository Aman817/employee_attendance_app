import 'package:employee_attendance_app/core/models/attendance_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceDatabase {
  static final AttendanceDatabase _instance = AttendanceDatabase._();
  static Database? _db;
  AttendanceDatabase._();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<AttendanceDatabase> create() async {
    return AttendanceDatabase._();
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE logs(
          id INTEGER PRIMARY KEY,
          timestamp TEXT,
          type TEXT,
          imagePath TEXT,
          latitude REAL,
          longitude REAL,
          address TEXT
        )
      ''');
    });
  }

  Future<void> insertLog(AttendanceModel log) async {
    final dbClient = await db;
    await dbClient.insert('logs', log.toJson());
  }

  Future<List<AttendanceModel>> getLogs() async {
    final dbClient = await db;
    final maps = await dbClient.query('logs', orderBy: 'timestamp DESC');
    return maps.map((map) => AttendanceModel.fromJson(map)).toList();
  }

  Future<List<AttendanceModel>> getlastLogs() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(Duration(days: 7));
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'logs',
      where: 'timestamp >= ?',
      whereArgs: [sevenDaysAgo.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel(
        id: maps[i]['id'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        type: maps[i]['type'],
        imagePath: maps[i]['imagePath'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        address: maps[i]['address'],
      );
    });
  }
}
