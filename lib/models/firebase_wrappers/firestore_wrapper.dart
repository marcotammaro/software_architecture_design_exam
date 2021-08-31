import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forat/models/firebase_wrappers/auth_wrapper.dart';

class FirestoreWrapper {
  // MARK: Singleton management
  static final FirestoreWrapper _singleton = FirestoreWrapper();
  static FirestoreWrapper get instance => _singleton;
  FirestoreWrapper() {
    _usersCollection = FirebaseFirestore.instance.collection('users');
    _lobbiesCollection = FirebaseFirestore.instance.collection('lobbies');
  }

  // MARK: Attributes

  CollectionReference _usersCollection;
  CollectionReference _lobbiesCollection;

  // MARK: Add Functions

  /// Create a new document in the users collection with the passed
  /// username as key
  Future addUser({String username}) async {
    await _usersCollection.doc(username).set({"username": username});
  }

  /// Add the passed username to the lobby that as the name as the
  /// passed lobbyName and increment the users counter
  Future addUserToLobby({String lobbyName, String username}) async {
    var foundedLobbies =
        await _lobbiesCollection.where('name', isEqualTo: lobbyName).get();

    if (foundedLobbies.docs.isEmpty) return;

    int currentUsersCount = foundedLobbies.docs.first.get('usersCount');

    String uid = foundedLobbies.docs.first.id;
    await _lobbiesCollection.doc(uid).update({
      "users": FieldValue.arrayUnion([username]),
      "usersCount": currentUsersCount + 1,
    });
  }

  /// Create a new document in the lobbies collection with the passed values
  Future<String> addLobby({String name, String description, int topic}) async {
    String username = AuthWrapper.instance.getCurrentUsername();
    DocumentReference ref = await _lobbiesCollection.add({
      "description": description,
      "name": name,
      "topic": topic,
      "users": [username],
      "lastMessage": "",
      "lastMessageTimestamp": 0,
      "usersCount": 1,
    });
    return ref.id;
  }

  /// Create a new document in the messages collection in a lobby that as the
  /// name as the passed lobbyName with the passed values
  Future<String> addMessage(
      {String text, DateTime dateTime, String lobbyName}) async {
    String username = AuthWrapper.instance.getCurrentUsername();

    // searching for correct lobby
    var foundedLobbies =
        await _lobbiesCollection.where('name', isEqualTo: lobbyName).get();
    String uid = foundedLobbies.docs.first.id;

    // setting lobby last message
    _lobbiesCollection.doc(uid).update({'lastMessage': text});
    _lobbiesCollection
        .doc(uid)
        .update({'lastMessageTimestamp': dateTime.millisecondsSinceEpoch});
    _lobbiesCollection.doc(uid).update({'lastMessageUsername': username});

    // saving message
    DocumentReference ref =
        await _lobbiesCollection.doc(uid).collection('messages').add({
      "text": text,
      "creator": username,
      "dateTime": dateTime.millisecondsSinceEpoch,
    });
    return ref.id;
  }

  // MARK: Remove functions

  /// Remove the passed username to the lobby that as the name as the
  /// passed lobbyName and increment the users counter
  Future removeUserToLobby({String lobbyName, String username}) async {
    var foundedLobbies =
        await _lobbiesCollection.where('name', isEqualTo: lobbyName).get();

    if (foundedLobbies.docs.isEmpty) return;

    int currentUsersCount = foundedLobbies.docs.first.get('usersCount');

    String uid = foundedLobbies.docs.first.id;
    await _lobbiesCollection.doc(uid).update({
      "users": FieldValue.arrayRemove([username]),
      "usersCount": currentUsersCount - 1,
    });
  }

  // MARK: Get functions

  /// Return a list of the first 5th lobbies for more users
  Future<List<QueryDocumentSnapshot<Object>>> getTrendLobbies() async {
    QuerySnapshot<Object> data = await _lobbiesCollection
        .orderBy('usersCount', descending: true)
        .limit(5)
        .get();
    return data.docs;
  }

  /// Return a list of 10 lobbies documents (if founded) where the name contains
  /// parts of the passed text
  Future<List<QueryDocumentSnapshot<Object>>> getTrendLobbiesWithNameContaining(
    String text,
  ) async {
    QuerySnapshot<Object> data =
        await _lobbiesCollection.where('name', isEqualTo: text).limit(10).get();

    return data.docs;
  }

  /// Return a list of 10 lobbies documents (if founded) where the topic is exactly
  /// corresponding to the passed topicIndex
  Future<List<QueryDocumentSnapshot<Object>>> getTrendLobbiesWithTopic(
    int topicIndex,
  ) async {
    QuerySnapshot<Object> data = await _lobbiesCollection
        .where('topic', isEqualTo: topicIndex)
        .limit(10)
        .get();
    return data.docs;
  }

  /// Return a the document of the lobbies with the provided id
  /// if no document is founded return null
  Future<DocumentSnapshot<Object>> getLobbiesWithId(
    String id,
  ) async {
    DocumentSnapshot<Object> doc = await _lobbiesCollection.doc(id).get();
    return doc;
  }

  // MARK: Get stream functions

  /// Get a stream connected to the lobies documents, if any lobby got
  /// update, the stream will update itself
  Future<Stream<QuerySnapshot>> getUserLobbiesStream() async {
    String username = AuthWrapper.instance.getCurrentUsername();
    return _lobbiesCollection
        .where('users', arrayContains: username)
        .snapshots();
  }

  /// Get a stream connected to the messages documents, if any message got
  /// update, the stream will update itself
  Future<Stream<QuerySnapshot>> getMessagesStream(String lobbyName) async {
    QuerySnapshot<Object> lobby =
        await _lobbiesCollection.where('name', isEqualTo: lobbyName).get();
    String uid = lobby.docs.first.id;

    return _lobbiesCollection.doc(uid).collection('messages').snapshots();
  }

  // MARK: Check functions

  /// Return true if the username already exist on the database, false otherwise
  Future<bool> checkForUniqueUsername({String username}) async {
    var document = await _usersCollection.doc(username).get();
    return (document.exists);
  }

  /// Return true if the lobby name already exist on the database, false otherwise
  Future<bool> checkForUniqueLobbyName({String lobbyName}) async {
    var document =
        await _lobbiesCollection.where('name', isEqualTo: lobbyName).get();
    return (document.docs.length > 0);
  }

  /// Return true if the current user has at least one lobby
  Future<bool> checkForUserLobbies() async {
    String username = AuthWrapper.instance.getCurrentUsername();
    QuerySnapshot<Object> data =
        await _lobbiesCollection.where('users', arrayContains: username).get();

    return data.docs.isNotEmpty;
  }
}
