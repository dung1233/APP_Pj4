import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:training_souls/screens/ol.dart';
import 'package:training_souls/screens/trainhome.dart';

class RunningTracker extends StatefulWidget {
  final int day;
  const RunningTracker({
    super.key,
    required this.day,
  });
  @override
  _RunningTrackerState createState() => _RunningTrackerState();
}

class _RunningTrackerState extends State<RunningTracker> {
  final MapController _mapController = MapController();
  List<LatLng> _route = [];
  double _distance = 0.0;
  bool _isTracking = false;
  LatLng? _lastPosition;
  bool _isLoading = true;
  Timer? _timer;
  int _secondsElapsed = 0;
  StreamSubscription<Position>? _positionStreamSubscription;
  double _totalDistance = 0;
  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadWorkoutData();
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    _stopTimer();
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  void _checkGoalAchieved() {
    if (_distance >= _totalDistance * 1000) {
      _stopTracking(); // Dừng theo dõi
      _saveWorkoutData(); // Lưu dữ liệu
      // Hoặc chuyển đến trang bạn muốn
    }
  }

  Future<void> _saveWorkoutData() async {
    try {
      final dbHelper = DatabaseHelper();

      final workoutResult = {
        "exerciseName": "Chạy bộ",
        "setsCompleted": 0,
        "repsCompleted": 0,
        "distanceCompleted": _distance / 1000,
        "durationCompleted": _secondsElapsed / 60
      };

      await dbHelper.saveExerciseResult(widget.day, workoutResult);
      if (kDebugMode) {
        print("[DEBUG] ✅ Đã lưu kết quả chạy bộ: $workoutResult");
      }
      await dbHelper.checkAndSyncWorkouts(widget.day);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Ol()),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("[DEBUG] ❌ Lỗi khi lưu kết quả chạy bộ: $e");
      }

      // Thêm kiểm tra mounted ở đây để tránh lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi lưu kết quả: $e")),
        );
      }
    }
  }

  // Hàm mới: Lấy dữ liệu từ SQLite
  Future<void> _loadWorkoutData() async {
    final dbHelper = DatabaseHelper();
    final allWorkouts = await dbHelper.getWorkouts();
    final runningWorkouts = allWorkouts
        .where((w) => w.day == widget.day && w.exerciseName == "Chạy bộ")
        .toList();

    // Kiểm tra trường đúng tên trong lớp Workout
    double firstDistance = runningWorkouts.isNotEmpty
        ? runningWorkouts[0].distance ??
            0.0 // Giả sử là 'distance', kiểm tra lại tên trường
        : 0.0;

    setState(() {
      _totalDistance = firstDistance; // Đảm bảo _totalDistance là double
      _isLoading = false;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng userLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _route = [userLocation];
      _lastPosition = userLocation;
      _isLoading = false;
    });

    _mapController.move(userLocation, 15.0);
  }

  void _startTracking() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      LatLng newPoint = LatLng(position.latitude, position.longitude);
      setState(() {
        if (_lastPosition != null) {
          _distance += Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            newPoint.latitude,
            newPoint.longitude,
          );
        }
        _lastPosition = newPoint;
        _route.add(newPoint);
      });
      _mapController.move(newPoint, 15.0);
      _checkGoalAchieved();
    });
  }

  void _toggleTracking() {
    setState(() {
      if (_isTracking) {
        _stopTimer();
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
        if (_route.isNotEmpty) {
          LatLng lastLocation = _route.last;
          _route = [lastLocation];
        }
      } else {
        _distance = 0.0;
        if (_route.isEmpty && _lastPosition != null) {
          _route.add(_lastPosition!);
        }
        _startTracking();
        _startTimer();
      }
      _isTracking = !_isTracking;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Outdoor Running", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Distance", style: TextStyle(color: Colors.white)),
                    Text(
                      "${_distance.toStringAsFixed(1)}m"
                      '/'
                      '${(_totalDistance * 1000).toStringAsFixed(0)}m', // _totalDistance chuyển từ km sang mét
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Time", style: TextStyle(color: Colors.white)),
                    Text(
                      _formatTime(_secondsElapsed),
                      style: TextStyle(color: Colors.white, fontSize: 26),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade900,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _isLoading || (_route.isEmpty && _lastPosition == null)
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Colors.orange[900]))
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _route.isNotEmpty
                              ? _route.first
                              : const LatLng(0.0, 0.0), // fallback location
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                  points: _route,
                                  color: Colors.blue,
                                  strokeWidth: 5.0),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              if (_route.isNotEmpty)
                                Marker(
                                  point: _route.first,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                ),
                              if (_lastPosition != null)
                                Marker(
                                  point: _lastPosition!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _toggleTracking,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.orange[900], shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _isTracking ? "STOP" : "GO",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
