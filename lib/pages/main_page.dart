import 'package:chat_app/helper/user_preferences.dart';
import 'package:chat_app/helper/utils.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/service/auth_services.dart';
import 'package:chat_app/service/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late var userName;
  late var userEmail;
  late var authService;

  @override
  void initState() {
    userName = UserPreferences.preferences!.getString("user_name")!;
    userEmail = UserPreferences.preferences!.getString("user_email")!;
    authService = AuthService();
    getGroupData();
    super.initState();
  }

  var groups;
  Future getGroupData() async {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupData()
        .then((snapshots) {
      setState(() {
        groups = snapshots;
      });
    });
  }

  getGroupName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getGroupId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getLastMessage(String groupId) {
    DatabaseServices().getLastMessage(groupId).then((value) {
      print("=== $value");
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SearchPage()));
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            const Icon(
              Icons.account_circle,
              color: Colors.teal,
              size: 120,
            ),
            Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              userEmail,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.group,
              ),
              selected: true,
              selectedColor: Colors.teal,
              title: const Text("Group"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
              ),
              title: const Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text("Logout"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "Logout",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        content: const Text("Are you sure want to Logout?"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                authService.logoutUser().then((value) {
                                  if (value == true) {
                                    Get.offAll(const LoginPage());
                                  } else {
                                    Utils.showCustomSnackBar(value.toString());
                                  }
                                });
                              },
                              child: const Text("Logout")),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: groups,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data['groups'] != null) {
                  // print("== snapshort has data ==");
                  if (snapshot.data['groups'].length > 0) {
                    // print("== snapshort is not blank ==");
                    return ListView.builder(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        itemCount: snapshot.data['groups'].length,
                        itemBuilder: (context, index) {
                          final reverseIndex =
                              snapshot.data['groups'].length - index - 1;
                          final userName = snapshot.data['user_name'];

                          final groupId =
                              getGroupId(snapshot.data['groups'][reverseIndex]);
                          // print("=== $groupId $userName");
                          String groupName = getGroupName(
                              snapshot.data['groups'][reverseIndex]);
                          getLastMessage(groupId);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                groupName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              maxRadius: 25,
                            ),
                            title: Text(
                              groupName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("${groupId}"),
                            onTap: () {
                              Get.to(ChatPage(
                                  groupId: groupId,
                                  groupName: groupName,
                                  userName: userName));
                            },
                          );
                        });
                  } else {
                    // print("== snapshort is blank ==");
                    return noGroupWidget();
                  }
                } else {
                  // print("== snapshort has no data ==");
                  return noGroupWidget();
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateGroupDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget noGroupWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              showCreateGroupDialog();
            },
            child: const Icon(
              Icons.add_circle,
              size: 40,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "You've  not join any group, tap on add icon or search on top search",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  bool isLoading = false;
  var groupName = "";
  showCreateGroupDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Create Group"),
            content: isLoading
                ? CircularProgressIndicator()
                : TextFormField(
                    onChanged: (value) {
                      groupName = value.trim();
                    },
                    decoration: InputDecoration(
                        label: Text("Group Name"),
                        hintText: "Enter group name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.red),
                        )),
                  ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () {
                    createGroup();
                  },
                  child: Text("Create")),
            ],
          );
        });
  }

  createGroup() {
    if (groupName != "") {
      setState(() {
        isLoading = true;
      });
      DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
          .createGroup(userName, groupName)
          .whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
      Navigator.of(context).pop();
      Utils.showCustomSnackBar("Group created successfully",
          title: "Success", isError: false);
    } else {
      Utils.showCustomSnackBar("Group name should not empty or null");
    }
  }
}
