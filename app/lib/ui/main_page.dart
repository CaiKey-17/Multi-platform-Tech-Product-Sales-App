import 'package:app/ui/product/product_details.dart';
import 'package:app/ui/screens/activity_page.dart';
import 'package:app/ui/screens/category_page.dart';
import 'package:app/ui/screens/home_page.dart';
import 'package:app/ui/screens/profile_page.dart';
import 'package:app/ui/screens/shopping_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;
  int? userId;
  String token = "";

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? -1;
      token = prefs.getString('token') ?? "";
      Future.microtask(() {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.fetchCartFromApi(userId);
      });
    });
  }

  List<Widget> pages = const [
    HomePage(),
    CategoryPageList(),
    ShoppingCartPage(isFromTab: true),
    ActivityPage(),
    ProfilePage(),
  ];

  final List<String> labels = [
    "Trang chủ",
    "Danh mục",
    "Giỏ hàng",
    "Hoạt động",
    "Cá nhân",
  ];
  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.assignment_turned_in_rounded,
    Icons.shopping_cart_rounded,
    Icons.assignment_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserData();

    pages = [
      const HomePage(),
      const CategoryPageList(),
      ShoppingCartPage(key: UniqueKey()),
      ActivityPage(key: UniqueKey()),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.blue,
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    labels.length,
                    (index) => SizedBox(
                      width: 60,
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              _selectedIndex == index
                                  ? Colors.white
                                  : const Color.fromARGB(255, 245, 231, 231),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 27,
              left: 0,
              right: 0,
              child: CurvedNavigationBar(
                height: 45,
                animationCurve: Curves.easeInOut,
                animationDuration: Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                color: Colors.blue,
                items: List.generate(
                  icons.length,
                  (index) =>
                      index == 2
                          ? badges.Badge(
                            badgeContent: Text(
                              cartProvider.cartItemCount.toString(),
                              style: TextStyle(
                                color:
                                    _selectedIndex == index
                                        ? Colors.white
                                        : const Color.fromARGB(
                                          255,
                                          245,
                                          231,
                                          231,
                                        ),
                                fontSize: 12,
                              ),
                            ),
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Colors.red,
                            ),
                            child: Icon(
                              icons[index],
                              size: 25,
                              color:
                                  _selectedIndex == index
                                      ? Colors.white
                                      : const Color.fromARGB(
                                        255,
                                        245,
                                        231,
                                        231,
                                      ),
                            ),
                          )
                          : Icon(
                            icons[index],
                            size: 25,
                            color:
                                _selectedIndex == index
                                    ? Colors.white
                                    : const Color.fromARGB(255, 245, 231, 231),
                          ),
                ),
                onTap: (index) {
                  if (index == 3 && token.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Vui lòng đăng nhập để xem hoạt động!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                    return;
                  }

                  setState(() {
                    _selectedIndex = index;
                    if (index == 2) {
                      pages[2] = ShoppingCartPage(key: UniqueKey());
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
