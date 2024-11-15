import 'package:agro/screens/chat/chatstart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  // Ambil daftar percakapan berdasarkan pengguna yang sedang login
  // Ambil daftar percakapan berdasarkan pengguna yang sedang login
Future<List<Map<String, dynamic>>> _getChats() async {
  List<Map<String, dynamic>> chats = [];

  // Ambil chat di mana currentUserId adalah buyer
  QuerySnapshot buyerChatSnapshot = await _firestore
      .collection('chats')
      .where('buyerId', isEqualTo: currentUserId)
      .get();

  // Ambil chat di mana currentUserId adalah seller
  QuerySnapshot sellerChatSnapshot = await _firestore
      .collection('chats')
      .where('sellerId', isEqualTo: currentUserId)
      .get();

  // Proses data chat sebagai buyer
  chats.addAll(await _processChatData(buyerChatSnapshot));

  // Proses data chat sebagai seller
  chats.addAll(await _processChatData(sellerChatSnapshot));

  return chats;
}

// Fungsi untuk memproses data chat dan mengambil pesan terakhir
Future<List<Map<String, dynamic>>> _processChatData(
    QuerySnapshot chatSnapshot) async {
  List<Map<String, dynamic>> processedChats = [];

  for (var doc in chatSnapshot.docs) {
    String chatId = doc.id;
    String sellerId = doc['sellerId'];
    String productId = doc['productId'];
    String productName = doc['productName'];
    String storeId = doc['storeId'];

    // Ambil pesan terakhir dari user1 dan user2 berdasarkan timestamp
    QuerySnapshot user1Messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('user1')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    QuerySnapshot user2Messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('user2')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    String lastMessage = 'No messages yet';
    Timestamp timestamp = Timestamp.now();

    // Cek pesan terbaru dari user1 dan user2
    if (user1Messages.docs.isNotEmpty) {
      lastMessage = user1Messages.docs.first['message'];
      timestamp = user1Messages.docs.first['timestamp'];
    }

    if (user2Messages.docs.isNotEmpty) {
      Timestamp user2Timestamp = user2Messages.docs.first['timestamp'];
      if (user2Timestamp.seconds > timestamp.seconds) {
        lastMessage = user2Messages.docs.first['message'];
        timestamp = user2Timestamp;
      }
    }

    // Simpan data percakapan yang telah diproses
    processedChats.add({
      'chatId': chatId,
      'sellerId': sellerId,
      'productId': productId,
      'productName': productName,
      'storeId': storeId,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    });
  }

  return processedChats;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat List"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chats available.'));
          }

          List<Map<String, dynamic>> chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final productName = chat['productName'];
              final lastMessage = chat['lastMessage'];
              final timestamp = chat['timestamp'] as Timestamp;
              final formattedTime =
                  DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000)
                      .toLocal()
                      .toString()
                      .substring(0, 16);

              return ListTile(
                leading: Icon(Icons.chat),
                title: Text(productName),
                subtitle: Text(lastMessage),
                trailing: Text(formattedTime),
                onTap: () {
                  // Arahkan ke halaman StartChat untuk percakapan ini
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartChat(
                        storeId: chat['storeId'],
                        productId: chat['productId'],
                        sellerId: chat['sellerId'],
                        productName: productName,
                        initialMessages: [], // Dapatkan pesan awal jika diperlukan
                        seller_name: null, // Isi jika ada nama seller
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
