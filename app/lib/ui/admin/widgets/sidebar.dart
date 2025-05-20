import 'package:app/globals/logout.dart';
import 'package:app/providers/profile_image_picker.dart';
import 'package:app/ui/admin/screens/brand_screen.dart';
import 'package:app/ui/admin/screens/category_screen.dart';
import 'package:app/ui/admin/screens/dashboard_advance_screen.dart';
import 'package:app/ui/chat/admin_chat_list_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/change_password_page.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_screen.dart';
import '../screens/user_screen.dart';
import '../screens/order_screen.dart';
import '../screens/coupon_screen.dart';
import '../screens/support_screen.dart';

class SideBar extends StatefulWidget {
  final String token;

  const SideBar({super.key, required this.token});
  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String image_url = "";
  String fullName = "";
  int? userId;
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      image_url = prefs.getString('image') ?? "";
      fullName = prefs.getString('fullName') ?? "";
      userId = prefs.getInt('userId') ?? -1;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: ProfileImagePicker(imageUrl: image_url),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    fullName,
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),

            _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            }),
            _buildDrawerItem(Icons.insights, 'Dashboard nâng cao', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            }),

            _buildDrawerItem(Icons.category, 'Quản lý loại sản phẩm', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen()),
              );
            }),

            _buildDrawerItem(
              Icons.branding_watermark,
              'Quản lý thương hiệu',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BrandScreen()),
                );
              },
            ),
            _buildDrawerItem(Icons.inventory_2, 'Quản lý sản phẩm', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductScreen()),
              );
            }),
            _buildDrawerItem(Icons.person, 'Quản lý người dùng', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserScreen()),
              );
            }),
            _buildDrawerItem(Icons.receipt, 'Quản lý đơn hàng', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderScreen()),
              );
            }),
            _buildDrawerItem(Icons.card_giftcard, 'Phiếu giảm giá', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CouponScreen()),
              );
            }),
            _buildDrawerItem(Icons.support_agent, 'Hỗ trợ khách hàng', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminChatListPage(userId: userId!),
                ),
              );
            }),

            _buildDrawerItem(Icons.password_outlined, 'Đổi mật khẩu', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChangePasswordScreen(token: widget.token),
                ),
              );
            }),
            _buildDrawerItem(Icons.logout, 'Đăng xuất', () {
              LogoutHelper.confirmLogout(context, () {});
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }
}
