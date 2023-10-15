import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/data/data_providers/apis.dart';
import 'package:chat_app/data/models/chat_user.dart';
import 'package:chat_app/data/models/message.dart';
import 'package:chat_app/presentation/widgets/message_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Chat extends StatefulWidget {
  const Chat({
    super.key,
    required this.user,
  });

  final ChatUser user;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Message> list = [];
  final TextEditingController _textController = TextEditingController();
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: Center(child: _appBar()),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
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

                        list = data!
                            .map((e) => Message.fromJson(e.data()))
                            .toList();

                        if (list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) =>
                                MessageaCard(message: list[index]),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'Say 👋 to ${widget.user.name} ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }
                    }
                  }),
            ),
            if (isUploading)
              const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(width: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  width: 45,
                  height: 45,
                  imageUrl: widget.user.image,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  if (list.isNotEmpty)
                    Text(
                      list[0].isOnline ? 'Active' : 'Currently not active',
                      style: const TextStyle(color: Colors.black54),
                    ),
                ],
              ),
            ],
          );
        });
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: 'Type something...',
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      for (var i in images) {
                        setState(() {
                          isUploading = true;
                        });
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() {
                          isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);

                      if (image != null) {
                        await APIs.sendChatImage(widget.user, File(image.path));
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            shape: const CircleBorder(),
            color: Colors.cyan,
            minWidth: 0,
            padding:
                const EdgeInsets.only(left: 12, bottom: 7, top: 7, right: 6),
            child: const Icon(
              Icons.send,
            ),
          )
        ],
      ),
    );
  }
}
