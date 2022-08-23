import 'package:chat_app/helper/user_preferences.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAdmin;
  const GroupInfoPage(
      {Key? key,
      required this.groupAdmin,
      required this.groupId,
      required this.groupName})
      : super(key: key);

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  late Stream members;
  late var userName;
  @override
  void initState() {
    userName = UserPreferences.preferences!.getString("user_name");
    getGroupMembers();
    super.initState();
  }

  void getGroupMembers() async {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getMembers(widget.groupId)
        .then((snapshort) {
      setState(() {
        members = snapshort;
      });
    });
  }

  getMemberName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getMemberId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Info"),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    widget.groupName.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  maxRadius: 25,
                ),
                title: Text(
                  "Group: " + widget.groupName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Admin: " + getMemberName(widget.groupAdmin)),
                onTap: () {},
              ),
            ),
            Expanded(
              child: Container(
                child: /*ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            widget.groupName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          maxRadius: 25,
                        ),
                        title: Text(
                          widget.groupName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.groupAdmin
                            .substring(widget.groupAdmin.indexOf("_") + 1)),
                        onTap: () {},
                      );
                    }),*/
                    StreamBuilder(
                        stream: members,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data['members'] != null) {
                              // print("== snapshort has data ==");
                              if (snapshot.data['members'].length > 0) {
                                // print("== snapshort is not blank ==");
                                return ListView.builder(
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    itemCount: snapshot.data['members'].length,
                                    itemBuilder: (context, index) {
                                      final reverseIndex =
                                          snapshot.data['members'].length -
                                              index -
                                              1;
                                      final memberName = getMemberName(
                                          snapshot.data['members'][index]);

                                      final memberId = getMemberId(
                                          snapshot.data['members'][index]);

                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                            memberName
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          maxRadius: 25,
                                        ),
                                        title: Text(
                                          memberName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(memberId),
                                        trailing: (memberName == userName &&
                                                memberName !=
                                                    getMemberName(
                                                        widget.groupAdmin))
                                            ? InkWell(
                                                onTap: () async {
                                                  await DatabaseServices(
                                                          uid: memberId)
                                                      .toggleGroupJoin(
                                                          widget.groupId,
                                                          memberName,
                                                          widget.groupName);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 15,
                                                      right: 15,
                                                      top: 10,
                                                      bottom: 10),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  child: Text(
                                                    "Exit",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: 20,
                                              ),
                                        onTap: () {},
                                      );
                                    });
                              } else {
                                // print("== snapshort is blank ==");
                                return Container();
                              }
                            } else {
                              // print("== snapshort has no data ==");
                              return Container();
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
