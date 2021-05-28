import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/message.dart';
import 'package:forat/models/topics.dart';
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

  Future<String> addLobby({String name, String description, int topic}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    DocumentReference ref = await lobbies.add({
      "description": description,
      "name": name,
      "topic": topic,
      "users": [username]
    });
    return ref.id;
  }

  Future addUserToLobby({String lobbyName, String username}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    var foundedLobbies =
        await lobbies.where('name', isEqualTo: lobbyName).get();

    if (foundedLobbies.docs.isEmpty) return;

    String uid = foundedLobbies.docs.first.id;
    await lobbies.doc(uid).update({
      "users": FieldValue.arrayUnion([username])
    });
  }

  Future<String> addMessage(
      {String text, DateTime dateTime, String lobbyName}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();

    var foundedLobbies =
        await lobbies.where('name', isEqualTo: lobbyName).get();
    String uid = foundedLobbies.docs.first.id;
    DocumentReference ref = await lobbies.doc(uid).collection('messages').add({
      "text": text,
      "creator": username,
      "dateTime": dateTime.toFirestore(),
    });
    return ref.id;
  }

  // MARK: Get functions

  Future<List<Lobby>> getUserLobbies() async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    QuerySnapshot<Object> data =
        await lobbies.where('users', arrayContains: username).get();

    List<Lobby> lobbyList = [];
    for (var doc in data.docs) {
      // Getting last message from this lobby
      var messageList = await getMessages(doc.get('name'));
      messageList.sort((a, b) {
        return a.dateTime.compareTo(b.dateTime);
      });

      // Creating lobby
      var lobby = Lobby.withKey(
        key: doc.id,
        name: doc.get('name'),
        description: doc.get('description'),
        topic: TopicsHelper.fromInt(doc.get('topic')),
        users: List<String>.from(doc.get('users')),
        lastMessage: messageList.isEmpty ? null : messageList.last,
      );

      lobbyList.add(lobby);
    }

    return lobbyList;
  }

  Future<List<Message>> getMessages(String lobbyName) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    QuerySnapshot<Object> lobby =
        await lobbies.where('name', isEqualTo: lobbyName).get();
    String uid = lobby.docs.first.id;

    QuerySnapshot<Object> messages =
        await lobbies.doc(uid).collection('messages').get();

    List<Message> messageList = [];
    for (var msgDoc in messages.docs) {
      messageList.add(Message.withKey(
        dateTime: DateTimeFirebaseHelper.fromFirestore(msgDoc.get('dateTime')),
        text: msgDoc.get('text'),
        username: msgDoc.get('creator'),
        key: msgDoc.id,
      ));
    }

    return messageList;
  }

  Future<Stream<QuerySnapshot>> getMessagesStream(String lobbyName) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    QuerySnapshot<Object> lobby =
        await lobbies.where('name', isEqualTo: lobbyName).get();
    String uid = lobby.docs.first.id;

    return lobbies.doc(uid).collection('messages').snapshots();
  }

  /// Return true if the username already exist on the database, false otherwise
  Future<bool> checkForUniqueUsername({String username}) async {
    var document = await firestore.collection('users').doc(username).get();
    return (document.exists);
  }

  /// Return true if the lobby name already exist on the database, false otherwise
  Future<bool> checkForUniqueLobbyName({String lobbyName}) async {
    var document = await firestore
        .collection('lobbies')
        .where('name', isEqualTo: lobbyName)
        .get();
    return (document.docs.length > 0);
  }
}
