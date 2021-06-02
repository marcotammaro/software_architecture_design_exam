import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';

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
      "users": [username],
      "lastMessage": "",
      "lastMessageTimestamp": 0,
      "usersCount": 1,
    });
    return ref.id;
  }

  Future addUserToLobby({String lobbyName, String username}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    var foundedLobbies =
        await lobbies.where('name', isEqualTo: lobbyName).get();

    if (foundedLobbies.docs.isEmpty) return;

    int currentUsersCount = foundedLobbies.docs.first.get('usersCount');

    String uid = foundedLobbies.docs.first.id;
    await lobbies.doc(uid).update({
      "users": FieldValue.arrayUnion([username]),
      "usersCount": currentUsersCount + 1,
    });
  }

  Future<String> addMessage(
      {String text, DateTime dateTime, String lobbyName}) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();

    // searching for correct lobby
    var foundedLobbies =
        await lobbies.where('name', isEqualTo: lobbyName).get();
    String uid = foundedLobbies.docs.first.id;

    // setting lobby last message
    lobbies.doc(uid).update({'lastMessage': text});
    lobbies
        .doc(uid)
        .update({'lastMessageTimestamp': dateTime.millisecondsSinceEpoch});

    // saving message
    DocumentReference ref = await lobbies.doc(uid).collection('messages').add({
      "text": text,
      "creator": username,
      "dateTime": dateTime.millisecondsSinceEpoch,
    });
    return ref.id;
  }

  // MARK: Get functions

  // Future<List<Lobby>> getUserLobbies() async {
  //   CollectionReference lobbies = firestore.collection('lobbies');
  //   String username = AuthWrapper.instance.getCurrentUsername();
  //   QuerySnapshot<Object> data =
  //       await lobbies.where('users', arrayContains: username).get();
  //
  //   List<Lobby> lobbyList = [];
  //   for (var doc in data.docs) {
  //     // Getting last message from this lobby
  //     var messageList = await getMessages(doc.get('name'));
  //     messageList.sort((a, b) {
  //       return a.dateTime.compareTo(b.dateTime);
  //     });
  //
  //     // Creating lobby
  // var lobby = Lobby.withKey(
  //   key: doc.id,
  //   name: doc.get('name'),
  //   description: doc.get('description'),
  //   topic: TopicsHelper.fromInt(doc.get('topic')),
  //   users: List<String>.from(doc.get('users')),
  //   lastMessage: Message(
  //     text: doc.get('lastMessage'),
  //     dateTime: DateTime.fromMillisecondsSinceEpoch(
  //       doc.get('lastMessageTimestamp'),
  //     ),
  //   ),
  //     );
  //
  //     lobbyList.add(lobby);
  //   }
  //
  //   return lobbyList;
  // }

  Future<List<QueryDocumentSnapshot<Object>>> getTrendLobbies() async {
    CollectionReference lobbies = firestore.collection('lobbies');

    QuerySnapshot<Object> data =
        await lobbies.orderBy('usersCount', descending: true).limit(1).get();
    return data.docs;
  }

  Future<Stream<QuerySnapshot>> getUserLobbiesStream() async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    return lobbies.where('users', arrayContains: username).snapshots();
  }

  // Future<List<Message>> getMessages(String lobbyName) async {
  //   CollectionReference lobbies = firestore.collection('lobbies');
  //   QuerySnapshot<Object> lobby =
  //       await lobbies.where('name', isEqualTo: lobbyName).get();
  //   String uid = lobby.docs.first.id;
  //
  //   QuerySnapshot<Object> messages =
  //       await lobbies.doc(uid).collection('messages').get();
  //
  //   List<Message> messageList = [];
  //   for (var msgDoc in messages.docs) {
  //     messageList.add(Message.withKey(
  //       dateTime: DateTimeFirebaseHelper.fromFirestore(msgDoc.get('dateTime')),
  //       text: msgDoc.get('text'),
  //       username: msgDoc.get('creator'),
  //       key: msgDoc.id,
  //     ));
  //   }
  //
  //   return messageList;
  // }

  Future<Stream<QuerySnapshot>> getMessagesStream(String lobbyName) async {
    CollectionReference lobbies = firestore.collection('lobbies');
    QuerySnapshot<Object> lobby =
        await lobbies.where('name', isEqualTo: lobbyName).get();
    String uid = lobby.docs.first.id;

    return lobbies.doc(uid).collection('messages').snapshots();
  }

  // MARK: Check functions

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

  /// Return true if the current user has at least one lobby
  Future<bool> checkForUserLobbies() async {
    CollectionReference lobbies = firestore.collection('lobbies');
    String username = AuthWrapper.instance.getCurrentUsername();
    QuerySnapshot<Object> data =
        await lobbies.where('users', arrayContains: username).get();

    return data.docs.isNotEmpty;
  }
}
