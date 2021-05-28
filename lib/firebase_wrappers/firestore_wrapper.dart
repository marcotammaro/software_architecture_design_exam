import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/utility/date_time_firebase_helper.dart';

class FirestoreWrapper {
  // MARK: Singleton management
  static final FirestoreWrapper _singleton = FirestoreWrapper._();
  static FirestoreWrapper get instance => _singleton;
  FirestoreWrapper._();

  // Attributes
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // MARK: Add Functions
  Future addUser({String username}) async {
    CollectionReference users = firestore.collection('users');
    await users.doc(username).set({"username": username});
  }

  Future addLobby({String name, String description, int topic}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    lobbies.add({
      "description": description,
      "name": name,
      "topic": topic,
      "users": [username]
    });
  }

  Future addUserToLobby({String lobbyName, String username}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    lobbies.where('name', isEqualTo: lobbyName).get().then((value) {
      String uid = value.docs.first.id;
      lobbies.doc(uid).update({
        "users": FieldValue.arrayUnion([username])
      });
    });
  }

  Future addMessage({String text, DateTime dateTime, String lobbyName}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    lobbies.where('name', isEqualTo: lobbyName).get().then((value) {
      String uid = value.docs.first.id;
      lobbies.doc(uid).collection('messages').add({
        "text": text,
        "creator": username,
        "dateTime": dateTime.toFirestore(),
      });
    });
  }

  // MARK: Get functions
  Future<List<QueryDocumentSnapshot<Object>>> getUserLobbies() async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    QuerySnapshot<Object> data =
        await lobbies.where('users', arrayContains: username).get();
    return data.docs;
  }

  // Future<List<QueryDocumentSnapshot<Object>>> getMessages(
  //     String lobbyName) async {
  //   CollectionReference lobbies = firestore.collection('lobbies');
  //   QuerySnapshot<Object> lobby =
  //       await lobbies.where('name', isEqualTo: lobbyName).get();
  //   String uid = lobby.docs.first.id;

  //   QuerySnapshot<Object> messages =
  //       await lobbies.doc(uid).collection('messages').get();
  //   return messages.docs;
  // }

  Future<Stream<QuerySnapshot>> getMessages(String lobbyName) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    QuerySnapshot<Object> lobby =
        await lobbies.where('name', isEqualTo: lobbyName).get();
    String uid = lobby.docs.first.id;

    return lobbies.doc(uid).collection('messages').snapshots();
  }

  /// Return true if the username already exist on the database, false otherwise
  Future<bool> checkForUsername({String username}) async {
    var document = await firestore.collection('users').doc(username).get();
    return (document.exists);
  }
}
