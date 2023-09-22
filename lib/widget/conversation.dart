import 'package:flutter/material.dart';

class ConversationList extends StatefulWidget {
  final String name;
  final String messageText;
  final String imageURL;
  final String messageType;
  //final String time;
  //final bool isMessageRead;
  const ConversationList({
    super.key,
    required this.name,
    required this.messageText,
    required this.imageURL,
    required this.messageType,
    //required this.isMessageRead,
    //required this.time
  });

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 10,
        ),
        child: Row(children: [
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.messageType == "model"
                  ? CircleAvatar(
                      backgroundImage: AssetImage(widget.imageURL),
                      maxRadius: 24,
                      backgroundColor: Colors.transparent,
                    )
                  : Container(),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Align(
                      alignment: widget.messageType == "model"
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.messageType == "model")
                              Text(
                                widget.name,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white70),
                              ),
                            const SizedBox(
                              height: 6,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: widget.messageType == "model"
                                      ? const Color.fromARGB(255, 46, 50, 52)
                                      : Colors.blue),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                widget.messageText,
                                textAlign: widget.messageType == "model"
                                    ? TextAlign.left
                                    : TextAlign.right,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ))),
            ],
          )),
        ]));

    // Text(
    //   widget.time,
    //   style: TextStyle(
    //     color: Colors.yellow,
    //     fontSize: 12,
    //     fontWeight:
    //         widget.isMessageRead ? FontWeight.bold : FontWeight.normal,
    //   ),
    // )
  }
}
