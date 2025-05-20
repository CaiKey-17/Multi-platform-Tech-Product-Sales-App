import 'package:app/ui/ai/detect_image.dart';
import 'package:app/ui/product/main_search.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<String> recentSearches = [];
  bool showAllRecent = false;
  int? userId;

  List<String> popularSearches = [
    "laptop",
    "tai nghe",
    "iphone",
    "loq",
    "dell",
    "trưng bày",
    "máy",
    "màn hình",
    "chuột",
  ];

  Future<void> _saveRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setStringList('recentSearches_$userId', recentSearches);
    }
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      List<String>? savedSearches = prefs.getStringList(
        'recentSearches_$userId',
      );
      if (savedSearches != null) {
        setState(() {
          recentSearches = savedSearches;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('userId') ?? -1;
    setState(() {
      userId = id;
    });
    await _loadRecentSearches();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _addToRecentSearches(String query) async {
    if (query.isNotEmpty && !recentSearches.contains(query)) {
      setState(() {
        recentSearches.insert(0, query);
      });
      await _saveRecentSearches();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchByNamePage(name: query)),
    );
    _searchController.clear();
  }

  Widget _buildSearchBar() {
    return Container(
      height: 37,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 0.3),
      ),
      child: Row(
        children: [
          if (!_focusNode.hasFocus)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.search, color: Colors.grey, size: 18),
            ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              onSubmitted: _addToRecentSearches,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Bạn muốn mua gì?",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  bottom: 10,
                  left: _focusNode.hasFocus ? 16 : 0,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.clear, color: Colors.grey, size: 18),
              ),
            ),

          IconButton(
            icon: Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 20),
            onPressed: () {
              ImageUploader(
                context: context,
                onResult: (result) {
                  setState(() {});
                },
              ).pickImageAndUpload();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    int displayCount = showAllRecent ? recentSearches.length : 5;
    bool shouldShowExpandButton = recentSearches.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TÌM KIẾM GẦN ĐÂY", style: TextStyle(fontWeight: FontWeight.bold)),

        ...recentSearches
            .take(displayCount)
            .map(
              (search) => ListTile(
                leading: Icon(Icons.history, size: 20),
                title: Text(search, style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchByNamePage(name: search),
                    ),
                  );
                },
              ),
            ),
        if (shouldShowExpandButton)
          TextButton(
            onPressed: () {
              setState(() {
                showAllRecent = !showAllRecent;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  showAllRecent ? "Thu gọn" : "Xem thêm",
                  style: TextStyle(color: Colors.blue),
                ),
                Icon(
                  showAllRecent ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(right: 16),
          child: _buildSearchBar(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRecentSearches(),
              Text(
                "TÌM KIẾM PHỔ BIẾN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    popularSearches.map((search) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SearchByNamePage(name: search),
                            ),
                          );
                        },
                        child: Chip(
                          label: Text(
                            search,
                            style: TextStyle(color: Colors.black87),
                          ),
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
