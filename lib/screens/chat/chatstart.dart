import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StartChat extends StatefulWidget {
  final String storeId;
  final String productId;
  final String sellerId;
  final String productName;

  StartChat({
    required this.storeId,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required List initialMessages,
    required seller_name,
  });

  @override
  _StartChatState createState() => _StartChatState();
}

class _StartChatState extends State<StartChat> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentUserId;
  String? currentUserName;
  String? sellerName;
  String? storeIdFromProduct;

  List<Map<String, dynamic>> user1Messages = [];
  String? chatId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchCurrentUser();
    _fetchSellerNameAndStoreId(() {
      _fetchOrCreateChat();
    });
  }

  void _fetchCurrentUser() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    if (userDoc.exists) {
      setState(() {
        currentUserName = userDoc['name'];
      });
    }
  }

  void _fetchSellerNameAndStoreId(VoidCallback onComplete) async {
    DocumentSnapshot productDoc =
        await _firestore.collection('products').doc(widget.productId).get();

    if (productDoc.exists) {
      setState(() {
        storeIdFromProduct = productDoc['storeId'];
        sellerName = productDoc['seller_name'];
      });
    }
    onComplete();
  }

  // Fungsi untuk memeriksa apakah chat sudah ada atau perlu dibuat baru
  Future<void> _fetchOrCreateChat() async {
    final generatedChatId = "${currentUserId}_${widget.sellerId}_${widget.productId}";

    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(generatedChatId).get();

    if (chatDoc.exists) {
      setState(() {
        chatId = generatedChatId;
      });
      _fetchChatHistory();
    } else {
      await _firestore.collection('chats').doc(generatedChatId).set({
        'buyerId': currentUserId,
        'sellerId': widget.sellerId,
        'storeId': storeIdFromProduct ?? widget.storeId,
        'productId': widget.productId,
        'productName': widget.productName,
        'seller_name': sellerName,
      });

      setState(() {
        chatId = generatedChatId;
      });
      _fetchChatHistory();
    }
  }

  void _fetchChatHistory() async {
    if (chatId != null) {
      QuerySnapshot user1Snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('user1')
          .orderBy('timestamp', descending: false)
          .get();

      setState(() {
        user1Messages = user1Snapshot.docs
            .where((doc) =>
                doc['senderId'] == currentUserId ||
                doc['senderId'] == widget.sellerId)
            .map((doc) {
          return {
            'type': doc['senderId'] == currentUserId
                ? 'sent_message'
                : 'received_message',
            'message': doc['message'],
            'timestamp': doc['timestamp'],
          };
        }).toList();
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    String message = _messageController.text.trim();

    if (chatId == null) {
      await _fetchOrCreateChat();
    }

    Map<String, dynamic> messageData = {
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': currentUserId,
    };

    bool isCurrentUserSeller = currentUserId == widget.sellerId;

    if (isCurrentUserSeller) {
      await _firestore.collection('chats').doc(chatId).collection('user2').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sellerId': currentUserId,
        'type': 'sent_message'
      });
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('user1')
          .add(messageData..['type'] = 'received_message');
    } else {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('user1')
          .add(messageData..['type'] = 'sent_message');
      await _firestore.collection('chats').doc(chatId).collection('user2').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sellerId': widget.sellerId,
        'type': 'received_message'
      });
    }

    setState(() {
      user1Messages.add({
        'type': 'sent_message',
        'message': message,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat dengan ${sellerName ?? 'Loading...'}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: user1Messages.length,
              itemBuilder: (context, index) {
                final message = user1Messages[index];
                bool isSent = message['type'] == 'sent_message';
                return Align(
                  alignment:
                      isSent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSent ? Colors.blue[200] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
