import 'dart:convert';
import 'dart:io';
import 'package:app/globals/ip.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatScreen extends StatefulWidget {
  final int userId;

  ChatScreen({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StompClient _stompClient;
  List<Map<String, dynamic>> _messages = [];
  TextEditingController _messageController = TextEditingController();
  late int _receiverId;
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _receiverId = 143;
    _connectWebSocket();
    _loadMessages();
  }

  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: ApiConfig.baseUrlWsc,
        onConnect: _onConnect,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
      ),
    );

    _stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Connected to WebSocket');
    _stompClient.subscribe(
      destination: '/topic/chat',
      callback: (frame) {
        if (frame.body != null) {
          final received = jsonDecode(frame.body!);
          setState(() {
            _messages.add(received);
          });
          _scrollToBottom();
        }
      },
    );
  }

  void _sendMessage({String? imageUrl}) {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final now = DateTime.now().toIso8601String();
    Map<String, dynamic> message = {
      'sender_id': widget.userId,
      'receiver_id': _receiverId,
      'content': text,
      'image': imageUrl ?? '',
      'sentAt': now,
    };

    _stompClient.send(
      destination: '/app/sendMessage',
      body: jsonEncode(message),
    );

    _messageController.clear();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      await uploadImageToCloudinary();
    }
  }

  Future<void> uploadImageToCloudinary() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final cloudinaryUrl = "https://api.cloudinary.com/v1_1/dwskd7iqr/upload";
      final uploadPreset = "flutter";

      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print("✅ Upload thành công: $imageUrl");

        _sendMessage(imageUrl: imageUrl);

        setState(() {
          _imageUrl = imageUrl;
          _selectedImage = null;
        });
      } else {
        print("❌ Lỗi khi upload: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      print("❌ Lỗi upload: $e");
    }

    setState(() => _isUploading = false);
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        ApiConfig.getChatMessages(widget.userId, _receiverId),
      );
      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body);
        setState(() {
          _messages = messages.map((e) => e as Map<String, dynamic>).toList();
        });
        _scrollToBottom();
      } else {
        print('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dt = DateTime.parse(isoTime);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == widget.userId;
    final content = msg['content'] ?? '';
    final time = _formatTime(msg['sentAt']);
    final imageUrl = msg['image'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[400] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (content.isNotEmpty)
                Text(
                  content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Text("Bộ phận CSKH", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i]),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: _pickImage,
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.keyboard_voice_rounded, color: Colors.blue),
                  onPressed: () {},
                ),

                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 36,
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Aa',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),

                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
