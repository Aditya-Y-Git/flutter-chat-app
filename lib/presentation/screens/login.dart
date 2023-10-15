import 'dart:io';
import 'package:chat_app/data/data_providers/apis.dart';
import 'package:chat_app/presentation/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // checking if user is already logged in then redirecting directly to home page
  @override
  void initState() {
    if (APIs.auth.currentUser != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Home(),
      ));
    }
    super.initState();
  }

  // Google sign-in 
  void _googleSignIn() {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    signInWithGoogle().then((value) async {
      Navigator.of(context).pop();
      if (value != null) {
        if (await APIs.userExists()) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const Home(),
          ));
        } else {
          await APIs.createUser().then((value) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const Home(),
            ));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // log('\nSignInWithGoogle: $e' as num);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Connect to internet!')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'LOGIN HERE',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
          ),
          ElevatedButton.icon(
            onPressed: _googleSignIn,
            icon: const Icon(
              Icons.login_outlined,
              color: Colors.black,
            ),
            label: const Text(
              'Login with Google',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
