import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController secretCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar'),
        backgroundColor: Color.fromRGBO(168, 207, 69, 1)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: secretCodeController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String secretCode = secretCodeController.text.trim();
                String password = passwordController.text.trim();
                

                if (email.isNotEmpty && secretCode.isNotEmpty && password.isNotEmpty ) {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);

                    // Tentukan role berdasarkan kode rahasia
                    String role = secretCode == "AMBATUKAM" ? "admin" : "user";

                    // Optional: Update display name after registration
                    await userCredential.user?.updateDisplayName(secretCode);

                    await FirebaseFirestore.instance
                        .collection('users') // Nama koleksi di Firestore
                        .doc(userCredential
                            .user?.uid) // Menggunakan UID sebagai ID dokumen
                        .set({
                      'uid': userCredential.user?.uid,
                      'name': secretCode,
                      'email': email,
                      'role': role, // Menyimpan role sebagai admin atau user
                      'createdAt': Timestamp.now(), // Waktu pendaftaran
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pendaftaran berhasil')),
                    );

                    // Kembali ke halaman login setelah pendaftaran berhasil
                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.message}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mohon isi semua kolom')),
                  );
                }
              },
              child: Text('Daftar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
