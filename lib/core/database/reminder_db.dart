import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReminderDatabaseHelper {
  static final ReminderDatabaseHelper _instance =
      ReminderDatabaseHelper._internal();
  factory ReminderDatabaseHelper() => _instance;

  static Database? _database;

  ReminderDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'reminder.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            checkInTime TEXT,
            checkOutTime TEXT
          )''');
      },
    );
  }

  Future<void> saveReminder(String checkInTime, String checkOutTime) async {
    final db = await database;
    await db.insert(
      'reminders',
      {'checkInTime': checkInTime, 'checkOutTime': checkOutTime},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String?>> getReminder() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('reminders', limit: 1);
    if (result.isNotEmpty) {
      return {
        'checkInTime': result[0]['checkInTime'],
        'checkOutTime': result[0]['checkOutTime']
      };
    }
    return {'checkInTime': null, 'checkOutTime': null};
  }
}
