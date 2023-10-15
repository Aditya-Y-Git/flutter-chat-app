import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/data/models/chat_user.dart';
import 'package:chat_app/presentation/screens/chat.dart';

class UserTile extends StatefulWidget {
  const UserTile({
    super.key,
    required this.user,
  });

  final ChatUser user;

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Chat(user: widget.user),
          ),
        );
      },
      child: Card(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: widget.user.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
