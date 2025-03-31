import 'package:app/models/work_out.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'workout_database.db');
    return await openDatabase(
      path,
      version: 3, // ⬆️ Tăng version để kích hoạt onUpgrade()
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // ✅ Thêm xử lý nâng cấp
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE workouts ADD COLUMN status TEXT DEFAULT "NOT_STARTED"');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE workouts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      day INTEGER,
      img TEXT,
      icon TEXT,
      exerciseName TEXT,
      sets INTEGER,
      reps INTEGER,
      duration INTEGER,
      restDay INTEGER,
      distance REAL,
      status TEXT DEFAULT 'NOT_STARTED'  -- ✅ Đã sửa lỗi dấu phẩy
    )
  ''');
  }

  // Thêm bài tập vào database
  Future<void> insertWorkout(Workout workout) async {
    final db = await database;
    await db.insert('workouts', workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lấy tất cả bài tập từ database
  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts');
    return List.generate(maps.length, (i) {
      return Workout.fromMap(maps[i]); // Chuyển đổi từ Map sang Workout
    });
  }

  // Xóa tất cả bài tập trong database
  Future<void> clearWorkouts() async {
    final db = await database;
    await db.delete('workouts');
  }

  Future<void> updateWorkoutStatus(int id, String newStatus) async {
    final db = await database;
    await db.update(
      'workouts',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
