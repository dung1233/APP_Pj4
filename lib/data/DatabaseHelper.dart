import 'package:training_souls/models/work_out.dart';
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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE workouts ADD COLUMN status TEXT DEFAULT "NOT_STARTED"'
      );
      await db.execute(_createWorkoutResultsTable);
    }
  }

  static const String _createWorkoutResultsTable = '''
    CREATE TABLE workout_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dayNumber INTEGER,
      exerciseName TEXT,
      setsCompleted INTEGER,
      repsCompleted INTEGER,
      distanceCompleted REAL,
      durationCompleted INTEGER
    )
  ''';

  Future<void> insertOrUpdateWorkoutResult({
    required int dayNumber,
    required String exerciseName,
    int setsCompleted = 0,
    int repsCompleted = 0,
    double distanceCompleted = 0.0,
    int durationCompleted = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> existing = await db.query(
      'workout_results',
      where: 'dayNumber = ? AND exerciseName = ?',
      whereArgs: [dayNumber, exerciseName],
    );

    if (existing.isNotEmpty) {
      final old = existing.first;
      final oldReps = old['repsCompleted'] ?? 0;
      final oldDistance = old['distanceCompleted'] ?? 0.0;

      if (repsCompleted > oldReps || distanceCompleted > oldDistance) {
        // 🔥 Nếu lần mới reps nhiều hơn hoặc distance xa hơn thì update
        await db.update(
          'workout_results',
          {
            'setsCompleted': setsCompleted,
            'repsCompleted': repsCompleted,
            'distanceCompleted': distanceCompleted,
            'durationCompleted': durationCompleted,
          },
          where: 'dayNumber = ? AND exerciseName = ?',
          whereArgs: [dayNumber, exerciseName],
        );
      }
    } else {
      await db.insert(
        'workout_results',
        {
          'dayNumber': dayNumber,
          'exerciseName': exerciseName,
          'setsCompleted': setsCompleted,
          'repsCompleted': repsCompleted,
          'distanceCompleted': distanceCompleted,
          'durationCompleted': durationCompleted,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getResultsByDay(int dayNumber) async {
    final db = await database;
    return await db.query(
      'workout_results',
      where: 'dayNumber = ?',
      whereArgs: [dayNumber],
    );
  }

  Future<void> clearWorkoutResults() async {
    final db = await database;
    await db.delete('workout_results');
  }

  Future<List<Map<String, dynamic>>> getAllWorkoutResults() async {
    final db = await database;
    return await db.query('workout_results');
  }

  Future<Map<String, dynamic>> exportResultsByDay(int dayNumber) async {
    final results = await getResultsByDay(dayNumber);
    return {
      'dayNumber': dayNumber,
      'results': results
    };
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
      status TEXT DEFAULT 'NOT_STARTED'
    )
  ''');
    await db.execute(_createWorkoutResultsTable);
  }

  Future<void> insertWorkout(Workout workout) async {
    final db = await database;
    await db.insert('workouts', workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts');
    return List.generate(maps.length, (i) {
      return Workout.fromMap(maps[i]);
    });
  }

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
  Future<void> updateWorkoutStatusByDayAndExercise({
    required int dayNumber,
    required String exerciseName,
    required String newStatus,
  }) async {
    final db = await database;
    await db.update(
      'workouts',
      {'status': newStatus},
      where: 'day = ? AND exerciseName = ?',
      whereArgs: [dayNumber, exerciseName],
    );
  }

}
