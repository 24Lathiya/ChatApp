import 'package:chat_app/pages/group_info_page.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  var admin = "";
  TextEditingController messageController = TextEditingController();

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    getAdminAndChats();
    super.initState();
  }

  void getAdminAndChats() async {
    DatabaseServices().getAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
    DatabaseServices().getChats(widget.groupId).then((snapshort) {
      setState(() {
        chats = snapshort;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(GroupInfoPage(
                    groupAdmin: admin,
                    groupId: widget.groupId,
                    groupName: widget.groupName));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chats,
              builder: (context, AsyncSnapshot snapshot) {
                return snapshot.hasData
                    ? ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          int reverseIndex =
                              snapshot.data.docs.length - index - 1;
                          return MessageTile(
                            message: snapshot.data.docs[reverseIndex]
                                ['message'],
                            sender: snapshot.data.docs[reverseIndex]['sender'],
                            sentByMe: widget.userName ==
                                snapshot.data.docs[reverseIndex]['sender'],
                            timeStamp: snapshot.data.docs[reverseIndex]['time'],
                          );
                        },
                      )
                    : Container(
                        child: Center(
                          child: Text("Enter first message"),
                        ),
                      );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[700],
            child: Row(children: [
              Expanded(
                  child: TextFormField(
                controller: messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Send a message...",
                  hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                  border: InputBorder.none,
                ),
              )),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () {
                  sendMessage();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                      child: Icon(
                    Icons.send,
                    color: Colors.white,
                  )),
                ),
              )
            ]),
          )
        ],
      ),
      /* bottomNavigationBar: Container(
        padding: EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[700],
        child: Row(children: [
          Expanded(
              child: TextFormField(
            controller: messageController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Send a message...",
              hintStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: InputBorder.none,
            ),
          )),
          const SizedBox(
            width: 12,
          ),
          GestureDetector(
            onTap: () {
              sendMessage();
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                  child: Icon(
                Icons.send,
                color: Colors.white,
              )),
            ),
          )
        ]),
      ),*/
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
