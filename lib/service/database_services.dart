import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  String? uid;
  DatabaseServices({this.uid});

  //reference for out collection
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //set user data
  Future setUserData(String userName, String email, String profile) async {
    return await userCollection.doc(uid).set({
      "uid": uid,
      "user_name": userName,
      "email": email,
      "profile": profile,
      "groups": []
    });
  }

  //get user data
  Future getUserData(String email) async {
    var snapshot = await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get group data

  Future getGroupData() async {
    return userCollection.doc(uid).snapshots();
  }

  Future getSearchGroupData(String groupName) async {
    return await groupCollection
        .where(
          "groupName",
          isEqualTo: groupName,
        )
        .get();

    /*return await Future.wait([
      userCollection.where("groupName", isEqualTo: groupName).get(),
      userCollection
          .where("groupName", isEqualTo: groupName.toUpperCase())
          .get(),
      userCollection
          .where("groupName", isEqualTo: groupName.toLowerCase())
          .get()
    ]);*/
  }

  Future createGroup(String userName, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupId": "",
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${uid}_$userName",
      "members": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
    });
  }

  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot.get("admin");
  }

  Future getMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future getLastMessage(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot.get("recentMessage");
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
