import 'package:cloud_firestore/cloud_firestore.dart';

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

  void addLobby() {}
  void addUserToLobby() {}
  void addMessage() {}

  // MARK: Get functions
  void getLobbies() {}
  void getMessages() {}

  /// Return true if the username already exist on the database, false otherwise
  Future<bool> checkForUsername({String username}) async {
    var document = await firestore.collection('users').doc(username).get();
    return (document.exists);
  }
}
