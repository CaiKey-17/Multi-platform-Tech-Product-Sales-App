import 'dart:convert';
import 'package:app/globals/ip.dart';
import 'package:app/ui/chat/admin_chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;
import 'chat_model.dart';
import 'package:app/ui/admin/widgets/sidebar.dart';

class AdminChatListPage extends StatefulWidget {
  final int userId;

  AdminChatListPage({required this.userId});
  @override
  _AdminChatListPageState createState() => _AdminChatListPageState();
}

class _AdminChatListPageState extends State<AdminChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> contacts = [];
  List<Chat> filteredChats = [];
  bool isLoading = true;
  late StompClient stompClient;
  String token = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterChats);
    fetchContacts();
    connectWebSocket();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  void onWebSocketConnected(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/chat',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final message = jsonDecode(frame.body!);
          print("New message received: $message");

          final userId = message['sender_id'];
          final newMessage = message['content'];

          _updateChat(userId, newMessage);
        }
      },
    );
  }

  void _markAsRead(int userId) {
    final idx = contacts.indexWhere((c) => c.userId == userId);
    if (idx != -1 && contacts[idx].unreadCount != 0) {
      setState(() {
        contacts[idx] = Chat(
          userId: contacts[idx].userId,
          userName: contacts[idx].userName,
          image: contacts[idx].image,
          lastMessage: contacts[idx].lastMessage,
          time: contacts[idx].time,
          unreadCount: 0,
        );
        _filterChats();
      });
    }
  }

  void _updateChat(int userId, String newMessage) {
    setState(() {
      final chatIndex = contacts.indexWhere((chat) => chat.userId == userId);
      if (chatIndex != -1) {
        contacts[chatIndex] = Chat(
          userId: contacts[chatIndex].userId,
          userName: contacts[chatIndex].userName,
          image: contacts[chatIndex].image,
          lastMessage: newMessage,
          time: TimeOfDay.now().format(context),
          unreadCount: contacts[chatIndex].unreadCount + 1,
        );
        _filterChats();
      }
    });
  }

  void connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: ApiConfig.baseUrlWsc,
        onConnect: onWebSocketConnected,
        onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer token'},
      ),
    );

    stompClient.activate();
  }

  Future<List<Chat>> fetchChatContacts(int currentUserId) async {
    final response = await http.get(ApiConfig.getChatContact(currentUserId));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) {
        final DateTime time = DateTime.parse(json['lastMessageTime']);
        final formattedTime =
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

        return Chat(
          userId: json['userId'],
          userName: json['fullName'],
          lastMessage: json['lastMessage'] ?? "",
          image: json['image'] ?? "",
          time: formattedTime,
          unreadCount: 0,
        );
      }).toList();
    } else {
      throw Exception("Failed to load chat contacts");
    }
  }

  void fetchContacts() async {
    final data = await fetchChatContacts(widget.userId);
    setState(() {
      contacts = data;
      filteredChats = data;
      isLoading = false;
    });
  }

  void _filterChats() {
    setState(() {
      if (_searchController.text.isEmpty) {
        filteredChats = contacts;
      } else {
        filteredChats =
            contacts
                .where(
                  (chat) => chat.userName.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hỗ trợ khách hàng", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: SideBar(token: token),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SizedBox(
              height: 35,
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Tìm kiếm",
                  hintStyle: TextStyle(fontSize: 12),
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return ListTile(
                      leading:
                          chat.image != ""
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(chat.image),
                              )
                              : CircleAvatar(child: Icon(Icons.person)),

                      title: Text(chat.userName),
                      subtitle: Text(chat.lastMessage),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(chat.time, style: TextStyle(color: Colors.grey)),
                          if (chat.unreadCount > 0)
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        if (!stompClient.isActive) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Đang kết nối đến máy chủ. Vui lòng thử lại sau.",
                              ),
                            ),
                          );
                          return;
                        }
                        _markAsRead(chat.userId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AdminChatDetailPage(
                                  userId: widget.userId,
                                  sentId: chat.userId,
                                  userName: chat.userName,
                                  stompClient: stompClient,
                                  onMessageSent: (msg) {
                                    _updateChat(chat.userId, msg);
                                    _markAsRead(chat.userId);
                                  },
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
