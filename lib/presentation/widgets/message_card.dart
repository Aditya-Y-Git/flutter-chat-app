import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/data/data_providers/apis.dart';
import 'package:chat_app/data/models/message.dart';
import 'package:chat_app/utils/format_date.dart';
import 'package:flutter/material.dart';

class MessageaCard extends StatefulWidget {
  const MessageaCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageaCard> createState() => _MessageaCardState();
}

class _MessageaCardState extends State<MessageaCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.senderId
        ? senderMessage()
        : receiverMessage();
  }

  Widget receiverMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            padding: EdgeInsets.all(widget.message.type == Type.text ? 15 : 5),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Text(
            FormatDate.getFormattedDate(
                context: context, time: widget.message.sent),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        )
      ],
    );
  }

  Widget senderMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 15),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_outlined,
                size: 20,
                color: Colors.blueAccent,
              ),
            const SizedBox(width: 2),
            Text(
              FormatDate.getFormattedDate(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15))),
            margin: const EdgeInsets.all(10),
            padding: EdgeInsets.all(widget.message.type == Type.text ? 15 : 5),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
