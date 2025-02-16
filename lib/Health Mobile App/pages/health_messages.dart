import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/chat_page.dart';
import 'package:mediwise/Health%20Mobile%20App/widgets/product_box.dart';
import 'package:mediwise/AI%20Bot/ai_chat_bot.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String searchQuery = "";
  bool showSearchBox = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleSearchBox() {
    setState(() {
      showSearchBox = !showSearchBox;
      if (showSearchBox) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        searchQuery = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    size: 25,
                  ),
                  const Text(
                    "Messages",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 30),
                    onPressed: toggleSearchBox,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizeTransition(
                sizeFactor: _animation,
                axisAlignment: -1.0,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (searchQuery.isEmpty)
                ProductBox(
                  name: "Mediwise AI Bot",
                  description: "Chat with our AI to know about YOU",
                  image: "mediwise.png",
                  isChatbot: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatScreen()),
                    );
                  },
                ),
              const SizedBox(height: 10),
            if (searchQuery.isEmpty)
              ProductBox(
                name: "Mediwise Image Bot",
                description: "Chat with your Images",
                image: "mediwise.png",
                isChatbot: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FileChatScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No users found."));
                    }

                    List<Widget> userList = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String userName = data['name'] ?? "Unknown User";
                      String userId = data['uid'];
                      String image = data['image'] ?? 'doc1.png';

                      if (searchQuery.isEmpty || userName.toLowerCase().contains(searchQuery)) {
                        return ProductBox(
                          name: userName,
                          description: "Say hello to $userName",
                          image: image,
                          isChatbot: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  recipientName: userName,
                                  recipientId: userId,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    }).toList();

                    return ListView(
                      children: userList.where((widget) => widget is! Container).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ProductBox extends StatelessWidget {
  final String name;
  final String description;
  final String image;
  final bool isChatbot;
  final VoidCallback onTap;

  const ProductBox({
    super.key,
    required this.name,
    required this.description,
    required this.image,
    this.isChatbot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 10.0),
        height: 100,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                "assets/doctor/$image",
                fit: BoxFit.fitHeight,
                width: 70,
                height: 80,
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0)),
                      Text(description),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
