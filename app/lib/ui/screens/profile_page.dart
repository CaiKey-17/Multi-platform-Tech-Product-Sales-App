import 'package:app/globals/logout.dart';
import 'package:app/providers/profile_image_picker.dart';
import 'package:app/providers/user_points_provider.dart';
import 'package:app/ui/login/change_password_page.dart';
import 'package:app/ui/login/edit_profile_page.dart';
import 'package:app/ui/login/login_page.dart';
import 'package:app/ui/login/register_page.dart';
import 'package:app/ui/profile/address_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "";
  int points = 0;
  String token = "";
  bool check = false;
  String formattedPoints = "";
  bool _isLoading = false;
  String image_url = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    Provider.of<UserPointsProvider>(
      context,
      listen: false,
    ).loadPointsFromPrefs();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? "";
      token = prefs.getString('token') ?? "";
      image_url = prefs.getString('image') ?? "";
      email = prefs.getString('email') ?? "";
      check = token.isNotEmpty;

      formattedPoints = NumberFormat("#,###", "de_DE").format(points);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: const BoxDecoration(color: Colors.white),
            ),
          ),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(children: _buildMenuItems()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/nenprofile.jpg"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child:
              _isLoading
                  ? _buildShimmerHeader()
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: ProfileImagePicker(imageUrl: image_url),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? "Khách" : fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "Điểm tích lũy:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '🪙 ${context.watch<UserPointsProvider>().formattedPoints}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildShimmerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 120, height: 18, color: Colors.grey[300]),
            ),
            const SizedBox(height: 10),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(width: 100, height: 16, color: Colors.grey[300]),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> items = [
      _buildMenuItem(Icons.person, "Thay đổi thông tin cá nhân", () {
        if (token.isEmpty) {
          Fluttertoast.showToast(
            msg: "Vui lòng đăng nhập",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
          return;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      EditProfilePage(fullName: fullName, email: email),
            ),
          ).then((_) => _loadUserData());
        }
      }),
      _buildMenuItem(Icons.location_history_outlined, "Sổ địa chỉ", () {
        if (token.isEmpty) {
          Fluttertoast.showToast(
            msg: "Vui lòng đăng nhập",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
          return;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddressListScreen()),
          );
        }
      }),

      check
          ? Column(
            children: [
              _buildMenuItem(Icons.password_rounded, "Thay đổi mật khẩu", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(token: token),
                  ),
                );
              }),
              _buildMenuItem(Icons.logout, "Đăng xuất", () {
                LogoutHelper.confirmLogout(context, () {});
              }),
            ],
          )
          : _buildMenuItem(Icons.account_circle_outlined, "Đăng nhập", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }),
    ];

    List<Widget> result = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i] is Column) {
        Column column = items[i] as Column;
        for (int j = 0; j < column.children.length; j++) {
          result.add(column.children[j]);
          if (j < column.children.length - 1) {
            result.add(
              const Divider(color: Colors.grey, thickness: 0.5, height: 0),
            );
          }
        }
      } else {
        result.add(items[i]);
      }
    }
    return result;
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title),
          onTap: onTap,
        ),
        const Divider(color: Colors.grey, thickness: 0.5, height: 0),
      ],
    );
  }
}
