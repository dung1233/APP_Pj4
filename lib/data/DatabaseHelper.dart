import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:training_souls/api/user_service.dart';
import 'package:training_souls/models/user.dart';
import 'package:training_souls/models/user_response.dart';
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
      version: 9, // Tăng version lên 9 từ 8
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("[DEBUG] Upgrading database from version $oldVersion to $newVersion");

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE workouts ADD COLUMN completionDate TEXT');
    }

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
    if (oldVersion < 6) {
      // Thêm bảng workout_results trong version 6
      await db.execute('''
        CREATE TABLE workout_results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          day_number INTEGER,
          exercise_name TEXT,
          sets_completed INTEGER,
          reps_completed INTEGER,
          distance_completed REAL,
          duration_completed INTEGER,
          completed_date TEXT
        )
      ''');
    }

    // Kiểm tra và thêm cột completionDate (version 8)
    if (oldVersion < 8) {
      try {
        // Kiểm tra xem cột đã tồn tại chưa
        var columns = await db.rawQuery('PRAGMA table_info(workouts)');
        bool hasCompletionDate =
            columns.any((column) => column['name'] == 'completionDate');

        if (!hasCompletionDate) {
          await db
              .execute('ALTER TABLE workouts ADD COLUMN completionDate TEXT');
          print("[DEBUG] ✅ Đã thêm cột completionDate vào bảng workouts");
        } else {
          print("[DEBUG] ℹ️ Cột completionDate đã tồn tại trong bảng workouts");
        }
      } catch (e) {
        print("[DEBUG] ❌ Lỗi khi thêm cột completionDate: $e");
      }
    }

    // Thêm cột workoutDate (version 9)
    if (oldVersion < 9) {
      try {
        // Kiểm tra xem cột đã tồn tại chưa
        var columns = await db.rawQuery('PRAGMA table_info(workouts)');
        bool hasWorkoutDate =
            columns.any((column) => column['name'] == 'workoutDate');

        if (!hasWorkoutDate) {
          await db.execute('ALTER TABLE workouts ADD COLUMN workoutDate TEXT');
          print("[DEBUG] ✅ Đã thêm cột workoutDate vào bảng workouts");
        } else {
          print("[DEBUG] ℹ️ Cột workoutDate đã tồn tại trong bảng workouts");
        }
      } catch (e) {
        print("[DEBUG] ❌ Lỗi khi thêm cột workoutDate: $e");
      }
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

    // Tạo bảng workouts (bài tập) - ĐÃ THÊM workoutDate vào định nghĩa
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
        status TEXT DEFAULT 'NOT_STARTED',
        completionDate TEXT,
        workoutDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_number INTEGER,
        exercise_name TEXT,
        sets_completed INTEGER,
        reps_completed INTEGER,
        distance_completed REAL,
        duration_completed INTEGER,
        completed_date TEXT
      )
    ''');
  }

  Future<void> checkAndCreateTables() async {
    final db = await database;
    var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='workout_results'");
    if (tables.isEmpty) {
      await db.execute('''
      CREATE TABLE workout_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_number INTEGER,
        exercise_name TEXT,
        sets_completed INTEGER,
        reps_completed INTEGER,
        distance_completed REAL,
        duration_completed INTEGER,
        completed_date TEXT
      )
      ''');
      print("[DEBUG] ✅ Đã tạo bảng workout_results");
    }
    // Kiểm tra bảng user_profile
    tables = await db.rawQuery(
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

    // Kiểm tra cột workoutDate trong bảng workouts
    var columns = await db.rawQuery('PRAGMA table_info(workouts)');
    bool hasWorkoutDate =
        columns.any((column) => column['name'] == 'workoutDate');

    if (!hasWorkoutDate) {
      try {
        await db.execute('ALTER TABLE workouts ADD COLUMN workoutDate TEXT');
        print("[DEBUG] ✅ Đã thêm cột workoutDate vào bảng workouts");
      } catch (e) {
        print("[DEBUG] ❌ Lỗi khi thêm cột workoutDate: $e");
      }
    }
  }

  Future<void> saveExerciseResult(
      int dayNumber, Map<String, dynamic> exerciseResult) async {
    final db = await database;

    try {
      // Kiểm tra xem bảng workout_results có tồn tại không
      var tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='workout_results'");
      if (tables.isEmpty) {
        // Tạo bảng nếu chưa có
        await db.execute('''
        CREATE TABLE workout_results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          day_number INTEGER,
          exercise_name TEXT,
          sets_completed INTEGER,
          reps_completed INTEGER,
          distance_completed REAL,
          duration_completed INTEGER,
          completed_date TEXT
        )
        ''');
        print("[DEBUG] ✅ Đã tạo bảng workout_results");
      }

      // Kiểm tra xem đã có kết quả cho ngày và bài tập này chưa
      final List<Map<String, dynamic>> existingResults = await db.query(
          'workout_results',
          where: 'day_number = ? AND exercise_name = ?',
          whereArgs: [dayNumber, exerciseResult['exerciseName']]);

      if (existingResults.isNotEmpty) {
        // Cập nhật kết quả hiện có
        await db.update(
            'workout_results',
            {
              'sets_completed': exerciseResult['setsCompleted'],
              'reps_completed': exerciseResult['repsCompleted'],
              'distance_completed': exerciseResult['distanceCompleted'],
              'duration_completed': exerciseResult['durationCompleted'],
              'completed_date': DateTime.now().toIso8601String()
            },
            where: 'day_number = ? AND exercise_name = ?',
            whereArgs: [dayNumber, exerciseResult['exerciseName']]);
        print("[DEBUG] ✏️ Đã cập nhật kết quả có sẵn");
      } else {
        // Thêm mới kết quả
        await db.insert('workout_results', {
          'day_number': dayNumber,
          'exercise_name': exerciseResult['exerciseName'],
          'sets_completed': exerciseResult['setsCompleted'],
          'reps_completed': exerciseResult['repsCompleted'],
          'distance_completed': exerciseResult['distanceCompleted'],
          'duration_completed': exerciseResult['durationCompleted'],
          'completed_date': DateTime.now().toIso8601String()
        });
        print("[DEBUG] ➕ Đã thêm kết quả mới");
      }
    } catch (e) {
      print("[DEBUG] ❌ Lỗi database: $e");
      throw e;
    }
  }

  Future<int> markWorkoutAsCompleted(int workoutId) async {
    final db = await database;

    // Format ngày hiện tại theo định dạng yyyy-MM-dd
    final String today = DateTime.now().toIso8601String().split('T')[0];

    return await db.update(
      'workouts',
      {
        'status': 'COMPLETED',
        'completionDate': today,
      },
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  // Phương thức để kiểm tra xem người dùng đã hoàn thành bài tập nào hôm nay
  Future<Workout?> getCompletedWorkoutForToday() async {
    final db = await database;
    final String today = DateTime.now().toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'completionDate = ? AND status = ?',
      whereArgs: [today, 'COMPLETED'],
    );

    if (maps.isNotEmpty) {
      return Workout.fromMap(maps.first);
    }

    return null;
  }

  // Phương thức mới để lấy tất cả bài tập theo ngày tập luyện cụ thể
  Future<List<Workout>> getWorkoutsByDate(String workoutDate) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'workoutDate = ?',
      whereArgs: [workoutDate],
    );

    return List.generate(maps.length, (i) {
      return Workout.fromMap(maps[i]);
    });
  }

  //mã đẩy lên dữ liệu lên
  Future<void> checkAndSyncWorkouts(int dayNumber) async {
    try {
      final db = await database;

      // Lấy tất cả kết quả cho ngày này
      final List<Map<String, dynamic>> results = await db.query(
          'workout_results',
          where: 'day_number = ?',
          whereArgs: [dayNumber]);

      // Nếu có đủ 4 bài tập, gửi lên API
      if (results.length >= 4) {
        print("[DEBUG] 🔄 Đã hoàn thành đủ bài tập, bắt đầu đồng bộ");

        // Định dạng lại dữ liệu theo cấu trúc API
        final List<Map<String, dynamic>> formattedResults = results
            .map((result) => {
                  "exerciseName": result['exercise_name'],
                  "setsCompleted": result['sets_completed'],
                  "repsCompleted": result['reps_completed'],
                  "distanceCompleted": result['distance_completed'],
                  "durationCompleted": result['duration_completed']
                })
            .toList();

        final Map<String, dynamic> apiData = {
          "dayNumber": dayNumber,
          "results": formattedResults
        };

        // Gửi lên API
        await sendToApi(apiData);

        // Sau khi gửi thành công, xóa dữ liệu local
        await db.delete('workout_results',
            where: 'day_number = ?', whereArgs: [dayNumber]);

        print("[DEBUG] ✅ Đã đồng bộ và xóa dữ liệu local");
      } else {
        print("[DEBUG] ⏳ Chưa đủ bài tập (${results.length}/4), đợi tiếp");
      }
    } catch (e) {
      print("[DEBUG] ❌ Lỗi khi kiểm tra và đồng bộ: $e");
    }
  }

  Future<void> sendToApi(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox('userBox');
      final token = box.get('token');
      final Dio dio = Dio();
      final response = await dio.post(
        'http://54.251.220.228:8080/trainingSouls/workout/workout-results',
        data: data,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 👈 Thêm token ở đây
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("[DEBUG] ✅ Gửi API thành công");
      } else {
        print("[DEBUG] ❌ Lỗi API: ${response.statusCode} - ${response.data}");
        throw Exception("API error: ${response.statusCode}");
      }
    } catch (e) {
      print("[DEBUG] ❌ Lỗi kết nối API: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutsForDate(
      String dateString) async {
    final db = await database;

    // Tìm tất cả kết quả tập luyện có ngày hoàn thành là ngày được chọn
    // Chúng ta tìm kiếm bằng cách so sánh phần đầu của chuỗi ngày (YYYY-MM-DD)
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT * FROM workout_results 
    WHERE completed_date LIKE '$dateString%'
    ORDER BY completed_date DESC
  ''');

    return results;
  }

  // Lấy tất cả kết quả từ bảng workout_results
  Future<List<Map<String, dynamic>>> getAllWorkoutResults() async {
    final db = await database;
    final List<Map<String, dynamic>> results =
        await db.query('workout_results');
    print("[DEBUG] 📊 Đã lấy ${results.length} kết quả từ workout_results");
    return results;
  }

  // Phương thức lấy tất cả kết quả cho một ngày cụ thể
  Future<Map<String, dynamic>> getDayResults(int dayNumber) async {
    final db = await database;

    final resultsList = await db.query('workout_results',
        where: 'day_number = ?', whereArgs: [dayNumber]);

    final formattedResults = {"dayNumber": dayNumber, "results": resultsList};

    return formattedResults;
  }

  // Thêm bài tập vào database với workoutDate
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

  // Phương thức lấy kết quả cho một ngày cụ thể và tên bài tập
  Future<List<Map<String, dynamic>>> getExerciseResults(int day) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'workout_results',
      where: 'day_number = ?',
      whereArgs: [day],
    );
    return results;
  }

  Future<void> insertExerciseResult(int day, String exerciseName) async {
    final db = await database;

    await db.insert(
      'exercise_results',
      {
        'day': day,
        'exercise_name': exerciseName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Nếu trùng thì thay
    );
  }

  Future<void> updateUserInfoInDatabase(User user) async {
    final db = await database;

    try {
      await db.transaction((txn) async {
        // 1. Xóa dữ liệu user cũ
        await txn.delete('user_info');

        // 2. Thêm thông tin user mới
        final userInfoMap = {
          'userID': user.userID, // Giữ userID từ API
          'name': user.name,
          'email': user.email,
          'accountType': user.accountType,
          'points': user.points,
          'level': user.level,
        };

        await txn.insert('user_info', userInfoMap);

        // 3. Cập nhật user_profile
        final userProfileExists = await txn.query('user_profile',
            where: 'userID = ?', whereArgs: [user.userID]);

        final userProfileMap = {
          'userID': user.userID,
          'gender': user.userProfile.gender,
          'age': user.userProfile.age,
          'height': user.userProfile.height,
          'weight': user.userProfile.weight,
          'bmi': user.userProfile.bmi,
          'bodyFatPercentage': user.userProfile.bodyFatPercentage,
          'muscleMassPercentage': user.userProfile.muscleMassPercentage,
          'activityLevel': user.userProfile.activityLevel,
          'fitnessGoal': user.userProfile.fitnessGoal,
          'level': user.userProfile.level,
          'strength': user.userProfile.strength,
          'deathPoints': user.userProfile.deathPoints,
          'agility': user.userProfile.agility,
          'endurance': user.userProfile.endurance,
          'health': user.userProfile.health,
        };

        if (userProfileExists.isEmpty) {
          await txn.insert('user_profile', userProfileMap);
        } else {
          await txn.update('user_profile', userProfileMap,
              where: 'userID = ?', whereArgs: [user.userID]);
        }

        // 4. Cập nhật roles (nếu cần)
        // Xóa roles cũ
        await txn
            .delete('roles', where: 'userID = ?', whereArgs: [user.userID]);

        // Thêm roles mới
        for (var role in user.roles) {
          await txn.insert('roles', {
            'userID': user.userID,
            'name': role.name,
            'description': role.description,
          });
        }
      });

      print(
          "[DEBUG] ✅ Đã cập nhật thông tin user, profile và roles trong database");
    } catch (e) {
      print("[DEBUG] ❌ Lỗi cập nhật database: $e");
      throw e;
    }
  }

  Future<void> updateUserInfoFromAPI() async {
    try {
      // Lấy token từ Hive
      var box = await Hive.openBox('userBox');
      final token = box.get('token');

      if (token == null) {
        throw Exception("Token không tồn tại, vui lòng đăng nhập lại");
      }

      // Tạo đối tượng API Service
      final dio = Dio();
      final userService = UserService(dio);

      // Gọi API để lấy thông tin người dùng mới
      final UserResponse userResponse =
          await userService.getMyInfo("Bearer $token");

      // Truy cập thuộc tính result (đối tượng User)
      final User user = userResponse.result;

      // Cập nhật thông tin vào database
      await updateUserInfoInDatabase(user);

      print("[DEBUG] ✅ Đã cập nhật thông tin người dùng từ API thành công");
    } catch (e) {
      print("[DEBUG] ❌ Lỗi khi cập nhật thông tin từ API: $e");
      throw e;
    }
  }
}
