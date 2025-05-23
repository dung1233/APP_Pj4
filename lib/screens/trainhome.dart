import 'package:training_souls/screens/BaoCao/report_screen.dart';
import 'package:training_souls/screens/Khampha/explore_screen.dart';

import 'package:training_souls/screens/Train/train_screen.dart';
import 'package:training_souls/screens/User/user_screen.dart';
import 'package:training_souls/screens/Shop/shop_screen.dart'; // Import ShopScreen
import 'package:flutter/material.dart';

class Trainhome extends StatefulWidget {
  final int initialIndex;

  const Trainhome({this.initialIndex = 0});

  @override
  // ignore: library_private_types_in_public_api
  _TrainhomeState createState() => _TrainhomeState();
}

class _TrainhomeState extends State<Trainhome> {
  late int selectedIndex;
  late PageController _pageController;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: selectedIndex);

    // Khởi tạo màn hình với dữ liệu
    _screens = [
      TrainScreen(), // Truyền vào đây
      ExploreScreen(),
      ReportScreen(),
      ShopScreen(),
      UserProfilePage(),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      selectedIndex = index;
      // Trigger focus and reload for specific screens when selected
      if (index == 1) {
        // ExploreScreen
        Future.microtask(() {
          if (_screens[1] is ExploreScreen) {
            FocusScope.of(context).requestFocus();
            // Force rebuild of ExploreScreen
            setState(() {
              _screens[1] = ExploreScreen(key: UniqueKey());
            });
          }
        });
      } else if (index == 3) {
        // ShopScreen
        Future.microtask(() {
          if (_screens[3] is ShopScreen) {
            FocusScope.of(context).requestFocus();
            // Force rebuild of ShopScreen
            setState(() {
              _screens[3] = ShopScreen(key: UniqueKey());
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _screens = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: ThemeData(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: const Color(0xFFFF6F00),
            backgroundColor: Colors.white,
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: Color(0xFFFF6F00),
                    fontWeight: FontWeight.bold,
                  );
                }
                return const TextStyle(color: Color.fromARGB(255, 0, 0, 0));
              },
            ),
          ),
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: selectedIndex,
          onDestinationSelected: _onTabChanged,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home,
                  color: selectedIndex == 0 ? Colors.white : Colors.black),
              label: 'Trang Chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore,
                  color: selectedIndex == 1 ? Colors.white : Colors.black),
              label: 'Khám Phá',
            ),
            NavigationDestination(
              icon: Icon(Icons.timeline,
                  color: selectedIndex == 2 ? Colors.white : Colors.black),
              label: 'Báo Cáo',
            ),
            NavigationDestination(
              icon: Icon(Icons.shop,
                  color: selectedIndex == 3 ? Colors.white : Colors.black),
              label: 'Cửa Hàng', // Đúng vị trí của ShopScreen
            ),
            NavigationDestination(
              icon: Icon(Icons.person,
                  color: selectedIndex == 4 ? Colors.white : Colors.black),
              label: 'User', // Đúng vị trí của UserProfilePage
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 5,
        backgroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: selectedIndex, // Giữ nguyên trạng thái khi chuyển tab
        children: _screens,
      ),
    );
  }
}
