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
      version: 5, // Thay đổi từ 4 lên 5
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE workouts ADD COLUMN status TEXT DEFAULT "NOT_STARTED"');
    }
    if (oldVersion < 4) {
      // Cập nhật với các bảng mới
      await db.execute('''
        CREATE TABLE roles (
          roleID INTEGER PRIMARY KEY AUTOINCREMENT,
          userID INTEGER,
          name TEXT,
          description TEXT,
          FOREIGN KEY(userID) REFERENCES user_info(userID)
        )
      ''');

      await db.execute('''
        CREATE TABLE permissions (
          permissionID INTEGER PRIMARY KEY AUTOINCREMENT,
          roleID INTEGER,
          name TEXT,
          description TEXT,
          FOREIGN KEY(roleID) REFERENCES roles(roleID)
        )
      ''');

      await db.execute('''
        CREATE TABLE user_profile (
          userID INTEGER PRIMARY KEY,
          gender TEXT,
          age INTEGER,
          height REAL,
          weight REAL,
          bmi REAL,
          bodyFatPercentage REAL,
          muscleMassPercentage REAL,
          activityLevel TEXT,
          fitnessGoal TEXT,
          level TEXT,
          strength INTEGER,
          deathPoints INTEGER,
          agility INTEGER,
          endurance INTEGER,
          health INTEGER,
          FOREIGN KEY(userID) REFERENCES user_info(userID)
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng user_info
    await db.execute('''
      CREATE TABLE user_info (
        userID INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        accountType TEXT,
        points INTEGER,
        level INTEGER
      )
    ''');

    // Tạo bảng workouts (bài tập)
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
  }

  Future<void> checkAndCreateTables() async {
    final db = await database;

    // Kiểm tra bảng user_profile
    var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='user_profile'");
    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE user_profile (
        userID INTEGER PRIMARY KEY,
        gender TEXT,
        age INTEGER,
        height REAL,
        weight REAL,
        bmi REAL,
        bodyFatPercentage REAL,
        muscleMassPercentage REAL,
        activityLevel TEXT,
        fitnessGoal TEXT,
        level TEXT,
        strength INTEGER,
        deathPoints INTEGER,
        agility INTEGER,
        endurance INTEGER,
        health INTEGER,
        FOREIGN KEY(userID) REFERENCES user_info(userID)
      )
    ''');
    }

    // Kiểm tra bảng roles
    tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='roles'");
    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE roles (
        roleID INTEGER PRIMARY KEY AUTOINCREMENT,
        userID INTEGER,
        name TEXT,
        description TEXT,
        FOREIGN KEY(userID) REFERENCES user_info(userID)
      )
    ''');
    }

    // Kiểm tra bảng permissions
    tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='permissions'");
    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE permissions (
        permissionID INTEGER PRIMARY KEY AUTOINCREMENT,
        roleID INTEGER,
        name TEXT,
        description TEXT,
        FOREIGN KEY(roleID) REFERENCES roles(roleID)
      )
    ''');
    }
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
      return Workout.fromMap(maps[i]);
    });
  }

  // Xóa tất cả bài tập trong database
  Future<void> clearWorkouts() async {
    final db = await database;
    await db.delete('workouts');
  }

  // Cập nhật trạng thái bài tập
  Future<void> updateWorkoutStatus(int id, String newStatus) async {
    final db = await database;
    await db.update(
      'workouts',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Thêm user info
  Future<void> insertUserInfo(Map<String, dynamic> userInfo) async {
    final db = await database;
    await db.insert('user_info', userInfo,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getUserName() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_info');

    if (maps.isNotEmpty) {
      return maps.first['name'];
    }
    return null;
  }

  // Thêm roles
// Thêm roles và trả về roleID
  Future<int> insertRole(Map<String, dynamic> role) async {
    final db = await database;
    return await db.insert('roles', role,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Thêm permissions
  Future<void> insertPermission(Map<String, dynamic> permission) async {
    final db = await database;
    await db.insert('permissions', permission,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Thêm user profile
  Future<void> insertUserProfile(Map<String, dynamic> userProfile) async {
    final db = await database;
    await db.insert('user_profile', userProfile,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Lấy thông tin user (user_info + profile + roles)
  Future<Map<String, dynamic>> getUser(int userID) async {
    final db = await database;

    // Lấy user_info
    final userInfoResult =
        await db.query('user_info', where: 'userID = ?', whereArgs: [userID]);
    if (userInfoResult.isEmpty) return {};
    var userInfo = userInfoResult.first;

    // Lấy roles
    final rolesResult =
        await db.query('roles', where: 'userID = ?', whereArgs: [userID]);
    var roles = rolesResult.map((role) => role).toList();

    // Lấy user_profile
    final profileResult = await db
        .query('user_profile', where: 'userID = ?', whereArgs: [userID]);
    var userProfile = profileResult.isNotEmpty ? profileResult.first : {};

    return {
      'user_info': userInfo,
      'roles': roles,
      'user_profile': userProfile,
    };
  }
}
