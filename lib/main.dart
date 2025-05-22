import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_souls/screens/Home/Home_screen.dart';
import 'package:training_souls/screens/Home/Students_Screen.dart';
import 'package:training_souls/screens/Home/notifications_Screen.dart';
import 'package:training_souls/screens/Home/profile_screen.dart';
import 'package:training_souls/screens/Home/schedule_screen.dart';
import 'package:training_souls/screens/login_screen.dart';
import 'package:training_souls/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'models/student_model.dart';
import 'models/notification_model.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.messageId}");

  // Hiển thị notification ngay cả khi background
  await _showAwesomeNotification(message);
}

// Hàm hiển thị awesome notification
Future<void> _showAwesomeNotification(RemoteMessage message) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'training_souls_channel',
      title: message.notification?.title ?? 'Training Souls',
      body: message.notification?.body ?? 'Bạn có thông báo mới',
      bigPicture: 'asset://assets/images/notification_icon.png', // Tùy chọn
      largeIcon: 'asset://assets/images/app_icon.png', // Tùy chọn
      notificationLayout: NotificationLayout.BigText,
      payload:
          message.data.map((key, value) => MapEntry(key, value?.toString())),
      criticalAlert: false,
      wakeUpScreen: true,
      category: NotificationCategory.Message,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'VIEW',
        label: 'Xem chi tiết',
        actionType: ActionType.SilentAction,
      ),
      NotificationActionButton(
        key: 'DISMISS',
        label: 'Bỏ qua',
        actionType: ActionType.DismissAction,
        isDangerousOption: true,
      ),
    ],
  );
}

// Navigation key để handle navigation từ notification
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Xử lý khi tap notification
void _handleNotificationTap(Map<String, String?> payload) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  // Navigate đến trang thích hợp dựa vào payload
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) =>
          const MainScreen(initialIndex: 2), // Notifications tab
    ),
    (route) => false,
  );
}

// Awesome Notifications Listeners
@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  print('Action received: ${receivedAction.actionType}');
  print('Payload: ${receivedAction.payload}');

  if (receivedAction.buttonKeyPressed == 'VIEW') {
    // Xử lý khi user tap "Xem chi tiết"
    _handleNotificationTap(receivedAction.payload ?? {});
  }
}

@pragma("vm:entry-point")
Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification) async {
  print('Notification created: ${receivedNotification.id}');
}

@pragma("vm:entry-point")
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
  print('Notification displayed: ${receivedNotification.id}');
}

@pragma("vm:entry-point")
Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction) async {
  print('Notification dismissed: ${receivedAction.id}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Khởi tạo Awesome Notifications
  await AwesomeNotifications().initialize(
    // App icon (null sẽ dùng icon mặc định)
    null,
    [
      NotificationChannel(
        channelKey: 'training_souls_channel',
        channelName: 'Training Souls Notifications',
        channelDescription: 'Notification channel for Training Souls app',
        defaultColor: const Color(0xFF667EEA),
        ledColor: Colors.white,
        channelShowBadge: true,
        importance: NotificationImportance.High,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        criticalAlerts: false,
      )
    ],
    debug: true,
  );

  // Request notification permissions
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // Hiển thị system notification ngay cả khi app đang foreground
    _showAwesomeNotification(message);
  });

  // Handle notification tap when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification tapped from background: ${message.data}');
    _handleNotificationTap(
        message.data.map((key, value) => MapEntry(key, value?.toString())));
  });

  // Handle initial message (app opened from notification when terminated)
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print('App opened from terminated state: ${initialMessage.data}');
    _handleNotificationTap(initialMessage.data
        .map((key, value) => MapEntry(key, value?.toString())));
  }

  // Listen to awesome notification actions
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Coach Training App',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

// Thêm vào AuthWrapper để kiểm tra permission
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _setupFCMPermissions();
  }

  Future<void> _setupFCMPermissions() async {
    // Request permission
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Handle initial message (when app is opened from notification)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification: ${initialMessage.data}');
    }
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated ? const MainScreen() : const LoginScreen();
  }
}

// Update MainScreen để support initialIndex
class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const HomeScreen(),
    const StudentsScreen(),
    const NotificationsScreen(),
    const ScheduleScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Check notification permissions khi vào main screen
    _checkNotificationPermissions();
  }

  Future<void> _checkNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show dialog để yêu cầu permission
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cho phép thông báo'),
            content: const Text(
                'Ứng dụng cần quyền gửi thông báo để bạn không bỏ lỡ thông tin quan trọng.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await AwesomeNotifications()
                      .requestPermissionToSendNotifications();
                },
                child: const Text('Cho phép'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Học viên',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Thông báo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Lịch học',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}
