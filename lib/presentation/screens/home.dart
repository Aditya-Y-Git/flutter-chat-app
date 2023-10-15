import 'package:chat_app/data/data_providers/apis.dart';
import 'package:chat_app/data/models/chat_user.dart';
import 'package:chat_app/presentation/screens/login.dart';
import 'package:chat_app/presentation/widgets/user_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ChatUser> list = [];

  // checking user's active status
  @override
  void initState() {
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
      if (message.toString().contains('pause')) APIs.updateActiveStatus(false);
      return Future.value(message);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            'CHATS',
            style: TextStyle(
              fontSize: 18,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
          actions: [
            // sign-out button
            IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                await FirebaseAuth.instance.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const Login(),
                    ));
                  });
                });
              },
              icon: const Icon(
                Icons.logout_outlined,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) =>
                          UserTile(user: list[index]),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Oops! No chats found 🥲',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }
              }
            }));
  }
}
