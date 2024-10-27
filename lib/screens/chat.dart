import 'package:agro/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Chat extends StatefulWidget {
  final String sellerName; 
  final List<Map<String, dynamic>> initialMessages;

  Chat({required this.sellerName, required this.initialMessages, required String initialChatWith});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late List<Map<String, dynamic>> messages; // Daftar pesan dinamis
  TextEditingController messageController = TextEditingController();
  File? imageFile;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi dengan pesan awal dari widget
    messages = widget.initialMessages;
  }

  void sendMessage({String? text, File? image}) {
    if (text != null || text!.isNotEmpty || image != null) {
      setState(() {
        messages.add({
          'text': text,
          'image': image,
          'status': 'Terkirim',
          'time': DateTime.now().toLocal().toString().substring(11, 16),
        });
        messageController.clear();
      });

      // Mensimulasikan status pesan berubah menjadi "Dibaca" setelah 2 detik
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          messages[messages.length - 1]['status'] = 'Dibaca';
        });
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      sendMessage(image: imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${widget.sellerName}'),
        backgroundColor: Colors.lightGreen,
      ),
      body: messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum ada chat',
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ayo mulai percakapan dengan berbelanja!',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Mengarahkan ke halaman Dashboard
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(products: [], storeName: ''),
                        ),
                      );
                    },
                    child: Text('Ke Dashboard'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (message['image'] != null)
                                  Image.file(
                                    message['image'],
                                    width: 150,
                                    height: 150,
                                  )
                                else
                                  Text(message['text'] ?? ''),
                                SizedBox(height: 5),
                                Text(
                                  '${message['time']} • ${message['status']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: pickImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          sendMessage(text: messageController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
