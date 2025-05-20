import 'package:app/luan/models/user_info.dart';
import 'package:app/services/api_admin_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import '../screens/user_detail_screen.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String token = "";

  bool isLoading = false;
  List<UserInfo> users = [];
  late ApiAdminService apiAdminService;

  Future<void> fetchUsersManager() async {
    setState(() {
      isLoading = true;
    });
    try {
      final usersData = await apiAdminService.getAllUsers();

      print("API response: ${usersData.toString()}");
      setState(() {
        users = usersData;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy danh sách người dùng: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    apiAdminService = ApiAdminService(Dio());
    _loadUserData();
    fetchUsersManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          "Quản lý người dùng",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: SideBar(token: token),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: _buildUserList(context))],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsScreen(user: users[index]),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  backgroundImage:
                      user.image.isNotEmpty ? NetworkImage(user.image) : null,
                  child:
                      user.image.isEmpty
                          ? Text(
                            user.id.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                          : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await apiAdminService.toggleUserActive(user.id);
                      await fetchUsersManager();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Đã cập nhật trạng thái người dùng"),
                        ),
                      );
                    } catch (e) {
                      print("Lỗi khi cập nhật trạng thái: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Lỗi khi cập nhật trạng thái người dùng",
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    user.active != 1 ? Icons.lock : Icons.lock_open,
                    color: user.active != 1 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
