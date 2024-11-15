// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatList extends StatefulWidget {
//   final String storeId;
//   final String productId;
//   final String sellerId;
//   final String productName;

//   ChatList({
//     required this.storeId,
//     required this.productId,
//     required this.sellerId,
//     required this.productName, required String sellerName, required List initialMessages, required String initialChatWith,
//   });

//   @override
//   _ChatListState createState() => _ChatListState();
// }

// class _ChatListState extends State<ChatList> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   String? currentUserId;
//   String? sellerName;
//   String? storeIdFromProduct;

//   List<Map<String, dynamic>> sentMessages = [];
//   List<Map<String, dynamic>> receivedMessages = [];

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     _fetchSellerNameAndStoreId();
//     _fetchChatHistory();
//   }

//   // Ambil nama penjual dan storeId dari produk
//   void _fetchSellerNameAndStoreId() async {
//     DocumentSnapshot productDoc =
//         await _firestore.collection('products').doc(widget.productId).get();

//     if (productDoc.exists) {
//       setState(() {
//         storeIdFromProduct = productDoc['storeId'];
//         sellerName = productDoc['seller_name']; // Ambil seller_name langsung dari produk
//       });
//     }
//   }

//   // Mengambil riwayat chat
//   void _fetchChatHistory() async {
//     QuerySnapshot chatSnapshot = await _firestore
//         .collection('chats')
//         .where('productId', isEqualTo: widget.productId)
//         .where('sellerId', isEqualTo: widget.sellerId)
//         .get();

//     if (chatSnapshot.docs.isNotEmpty) {
//       String chatId = chatSnapshot.docs.first.id;

//       // Ambil pesan yang telah dikirim
//       QuerySnapshot sentSnapshot = await _firestore
//           .collection('chats')
//           .doc(chatId)
//           .collection('sent_message')
//           .orderBy('timestamp', descending: false) // Ubah urutan menjadi ascending
//           .get();

//       // Ambil pesan yang diterima
//       QuerySnapshot receivedSnapshot = await _firestore
//           .collection('chats')
//           .doc(chatId)
//           .collection('received_message')
//           .orderBy('timestamp', descending: false) // Ubah urutan menjadi ascending
//           .get();

//       setState(() {
//         sentMessages = sentSnapshot.docs.map((doc) {
//           return {
//             'senderId': doc['senderId'],
//             'message': doc['message'],
//             'timestamp': doc['timestamp'],
//           };
//         }).toList();

//         receivedMessages = receivedSnapshot.docs.map((doc) {
//           return {
//             'senderId': doc['senderId'],
//             'message': doc['message'],
//             'timestamp': doc['timestamp'],
//           };
//         }).toList();
//       });
//     }
//   }

//   // Mengirim pesan ke Firestore
//   void _sendMessage() async {
//     if (_messageController.text.isNotEmpty) {
//       String message = _messageController.text.trim();

//       // Cari chat ID yang ada
//       QuerySnapshot chatSnapshot = await _firestore
//           .collection('chats')
//           .where('productId', isEqualTo: widget.productId)
//           .where('sellerId', isEqualTo: widget.sellerId)
//           .get();

//       String chatId;
//       if (chatSnapshot.docs.isNotEmpty) {
//         chatId = chatSnapshot.docs.first.id;
//       } else {
//         // Jika belum ada chat, buat chat baru
//         DocumentReference newChatRef = await _firestore.collection('chats').add({
//           'sellerId': widget.sellerId,
//           'storeId': storeIdFromProduct ?? widget.storeId,
//           'productId': widget.productId,
//           'productName': widget.productName,
//           'seller_name': sellerName,
//         });
//         chatId = newChatRef.id;
//       }

//       // Simpan pesan ke subkoleksi sent_message
//       await _firestore.collection('chats').doc(chatId).collection('sent_message').add({
//         'senderId': currentUserId,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Simpan pesan yang diterima di subkoleksi received_message
//       await _firestore.collection('chats').doc(chatId).collection('received_message').add({
//         'senderId': widget.sellerId,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(), // Jika diperlukan, bisa mengganti dengan server timestamp saat menerima pesan
//       });

//       setState(() {
//         sentMessages.add({
//           'senderId': currentUserId,
//           'message': message,
//           'timestamp': DateTime.now(),
//         });
//       });

//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat dengan ${sellerName ?? 'Loading...'}"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: sentMessages.length + receivedMessages.length,
//               itemBuilder: (context, index) {
//                 // Menentukan pesan berdasarkan indeks
//                 if (index < receivedMessages.length) {
//                   final message = receivedMessages[index];
//                   return Align(
//                     alignment: Alignment.centerLeft,
//                     child: Container(
//                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         message['message'],
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   );
//                 } else {
//                   final message = sentMessages[index - receivedMessages.length];
//                   return Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[200],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         message['message'],
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: "Tulis pesan...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
