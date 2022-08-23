import 'package:chat_app/helper/user_preferences.dart';
import 'package:chat_app/helper/utils.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var isEmpty = true;
  var isLoading = false;
  var hasUserSearched = false;
  var searchController = TextEditingController();
  bool isJoined = false;
  var userName = "";
  late User user;
  late QuerySnapshot groups;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser!;
    userName = UserPreferences.preferences!.getString("user_name")!;
    super.initState();
  }

  Future getGroupData(String groupName) async {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getSearchGroupData(groupName)
        .then((snapshots) {
      setState(() {
        groups = snapshots;
        isLoading = false;
        hasUserSearched = true;
      });
    });
  }

  getAdminName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: TextField(
              showCursor: true,
              controller: searchController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Group Name",
                  suffixIcon: InkWell(
                    onTap: () {
                      searchGroup(searchController.text.trim());
                    },
                    child: Icon(
                      Icons.search,
                    ),
                  )),
              onChanged: (value) {
                setState(() {
                  isEmpty = value.isEmpty;
                });
              },
            ),
          ),
          Expanded(
            child: /*isEmpty
                ? Container(
                    child: Center(
                      child: Text(
                        "Search group to join",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                :*/
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : hasUserSearched
                        ? groups.docs.length > 0
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: groups.docs.length,
                                itemBuilder: (context, index) {
                                  final groupId = groups.docs[index]['groupId'];
                                  final groupName =
                                      groups.docs[index]['groupName'];
                                  final adminName =
                                      getAdminName(groups.docs[index]['admin']);

                                  joinedOrNot(
                                      userName, groupId, groupName, adminName);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        groupName.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      maxRadius: 25,
                                    ),
                                    title: Text(
                                      groupName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("admin: $adminName"),
                                    trailing: userName == adminName
                                        ? Container(
                                            width: 30,
                                          )
                                        : Container(
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
                                                    BorderRadius.circular(15)),
                                            child: InkWell(
                                              onTap: () async {
                                                await DatabaseServices(
                                                        uid: user.uid)
                                                    .toggleGroupJoin(groupId,
                                                        userName, groupName);
                                                if (isJoined) {
                                                  setState(() {
                                                    isJoined = !isJoined;
                                                  });
                                                  Utils.showCustomSnackBar(
                                                      "Successfully joined the group",
                                                      title: "Success",
                                                      isError: false);
                                                  Future.delayed(
                                                      const Duration(
                                                          seconds: 2), () {
                                                    Get.to(ChatPage(
                                                        groupId: groupId,
                                                        groupName: groupName,
                                                        userName: userName));
                                                  });
                                                } else {
                                                  setState(() {
                                                    isJoined = !isJoined;
                                                    Utils.showCustomSnackBar(
                                                        "Left the group $groupName",
                                                        title: "Success",
                                                        isError: false);
                                                  });
                                                }
                                              },
                                              child: Text(
                                                isJoined ? "Exit" : "Join",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                    /* onTap: () {
                                      Get.to(ChatPage(
                                          groupId: groupId,
                                          groupName: groupName,
                                          userName: userName));
                                    },*/
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  "Group name not found",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                        : Container(
                            child: Center(
                              child: Text(
                                "Search group to join",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
          )
        ],
      ),
    );
  }

  void joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseServices(uid: user.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  void searchGroup(String searchText) {
    if (searchText.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      getGroupData(searchText);
    }
  }
}
