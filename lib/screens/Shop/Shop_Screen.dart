import 'package:app/screens/details/details_screen.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required Map<String, dynamic> userData});

  @override
  // ignore: library_private_types_in_public_api
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ["Cart", "Shoe", "Shirt", "Avatar"];

  // Dữ liệu giả thay thế API
  final Map<String, List<Map<String, dynamic>>> categoryProducts = {
    "Cart": [
      {
        "title": "Premium Account ",
        "price": 20,
        "image": "assets/img/prim.jpg",
      },
    ],
    "Shoe": [
      {"title": "Shoe Item", "price": 5, "image": "assets/img/shoe.jpg"},
      {"title": "Shoe Item", "price": 5, "image": "assets/img/shoe1.jpg"},
      {"title": "Shoe Item", "price": 5, "image": "assets/img/shoe2.jpg"},
    ],
    "Shirt": [
      {"title": "AI Item ", "price": 5, "image": "assets/img/sh.jpg"},
      {"title": "AI Item ", "price": 5, "image": "assets/img/sh1.jpg"},
    ],
    "Avatar": [
      {"title": "Avatar Item ", "price": 5, "image": "assets/img/avatar.jpg"},
      {"title": "Avatar Item ", "price": 5, "image": "assets/img/avatar1.jpg"},
      {"title": "Avatar Item ", "price": 5, "image": "assets/img/avatar3.jpg"},
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // Xóa bóng AppBar
          shadowColor: Colors.transparent, // Xóa bóng hoàn toàn
          title: const Text(
            "Shop",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            // Xóa gạch dưới tab
            labelColor: Colors.black, // Màu tab được chọn
            unselectedLabelColor: Colors.grey, // Màu tab chưa chọn
            dividerColor: Colors.transparent, // Xóa đường kẻ ngang dưới tab
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              return GridView.builder(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.85,
                ),
                itemCount: categoryProducts[category]!.length,
                itemBuilder: (context, index) {
                  var product = categoryProducts[category]![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DetailsScreen(product)),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  product['image'],
                                  fit: BoxFit.cover,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2.5),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                product['title'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2.5),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "\$${product['price']}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
