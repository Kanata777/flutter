import 'package:agro/consts/gambar.dart';
import 'package:agro/screens/dashboard.dart';
import 'package:agro/screens/dashboard_admin.dart';
import 'package:agro/screens/forgotpass.dart';
import 'package:agro/screens/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> _onWillPop() async {
    // Mencegah navigasi kembali ke halaman dashboard
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
          automaticallyImplyLeading: false,
          title: Text(
            'Login',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  IconAgro,
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 20),
                Align(alignment: Alignment.centerLeft, child: Text('Email')),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    prefixIconColor: Colors.black,
                  ), 
                ),
                SizedBox(height: 20),
                Align(alignment: Alignment.centerLeft, child: Text('Password')),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    prefixIconColor: Colors.black,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPass()),
                      );
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap isi semua kolom')),
                      );
                    } else {
                      try {
                        // Login menggunakan Firebase Authentication
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                                email: email, password: password);

                        // Dapatkan UID pengguna yang berhasil login
                        String userId =
                            userCredential.user?.uid ?? 'Unknown User';

                        // Dapatkan role dari Firestore
                        DocumentSnapshot userDoc = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(userId)
                            .get();

                        String role = userDoc.get('role') ?? 'user';

                        // Simpan status login dan userId ke SharedPreferences
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isLoggedIn', true);
                        await prefs.setString('userEmail', email);
                        await prefs.setString('userId', userId);

                        // Login berhasil
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login Berhasil')),
                        );

                        // Navigasi ke halaman dashboard berdasarkan role
                        if (role == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdminDashboard(products: []), // Halaman admin
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(products: []), // Halaman user biasa
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pengguna tidak ditemukan')),
                          );
                        } else if (e.code == 'wrong-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password salah')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Terjadi kesalahan: ${e.message}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Terjadi kesalahan: $e')),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Masuk',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
                    minimumSize: Size(105, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: Text(
                    'Belum Punya Akun? Daftar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
