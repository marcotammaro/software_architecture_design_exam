import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/lobbies_event.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/models/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/models/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/logic/notification_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/topics.dart';
import 'package:forat/views/lobby_creation_view.dart';
import 'package:forat/views/lobby_details_view.dart';
import 'package:forat/views/lobby_info_view.dart';

class LobbyLogic {
  // Class Attributes
  BuildContext _streamContext;
  StreamSubscription<QuerySnapshot> _stream;
  AuthWrapper authWrapper;
  FirestoreWrapper firestoreWrapper;

  // Constructor
  LobbyLogic(
    this._streamContext, [
    AuthWrapper _authWrapper,
    FirestoreWrapper _firestoreWrapper,
  ]) {
    this.authWrapper = _authWrapper ?? AuthWrapper.instance;
    this.firestoreWrapper = _firestoreWrapper ?? FirestoreWrapper.instance;
    startListenLobbies();
  }

  // MARK: Utility Functions

  /// This function will start listening for lobbies snapshot on firebase
  void startListenLobbies() async {
    var value = await firestoreWrapper.getUserLobbiesStream();
    if (value != null) _stream = value.listen(onLobbiesEvent);
  }

  /// Callback called when the lobbies snapshot updates
  void onLobbiesEvent(QuerySnapshot<Object> event) async {
    // Removing all previous lobbies from the bloc
    BlocProvider.of<LobbiesBloc>(_streamContext).add(LobbiesEvent.deleteAll());
    for (var doc in event.docs) {
      var lobby = Lobby.fromMap(doc.data(), id: doc.id);
      BlocProvider.of<LobbiesBloc>(_streamContext).add(LobbiesEvent.add(lobby));
    }
  }

  /// Function to stop listening from lobbies snapshot
  /// Should be called once the listening view is dismissed
  void stopListenLobbies() {
    if (_stream != null) _stream.cancel();
  }

  /// Return true if user have lobbies
  Future<bool> userHaveLobbies() async {
    return await firestoreWrapper.checkForUserLobbies();
  }

  /// This function return true if the current user has logged in into the
  /// passed lobby; false otherwise
  Future<bool> checkForUserJoined({Lobby lobby}) async {
    return lobby.users.contains(authWrapper.getCurrentUsername());
  }

  // MARK: Navigator Logic

  static void goToLobbyCreationView(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_context) => LobbyCreationView()),
    );
  }

  static void goToLobbyDetailedView(BuildContext context, Lobby lobby) {
    /// Stop listen messages notification for the opened lobby
    NotificationLogic.instance.stopListenForLobby(lobby.key);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_context) => LobbyDetailsView(lobby: lobby)),
    );
  }

  static void goToLobbyInfoView(BuildContext context, Lobby lobby) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_context) => LobbyInfoView(lobby: lobby)),
    );
  }

  // MARK: Buttons Logic

  /// Function called when the user is in the LobbyCreationView and user tap on save button.
  /// This function will check for correct topicIndex and name; if some fields are incorrect, it will return false and show an error screen.
  /// If everything is fine, it will add the lobby to firestore and will return true once all operation have completed.
  Future<String> didTapOnCreateLobbyButton({
    String name,
    String description,
    int topicIndex,
  }) async {
    // Checking if user choose a topic for the lobby
    if (topicIndex == null) {
      return "Please, select a topic.";
    }
    // Checking if user choose a name for the lobby
    if (name == null || name == "") {
      return "Please, insert a name.";
    }

    // checking for unique lobby name
    bool alreadyExist =
        await firestoreWrapper.checkForUniqueLobbyName(lobbyName: name);

    // douplicated lobby name => show error
    if (alreadyExist) {
      return "The name of the lobby already exist";
    }

    await firestoreWrapper.addLobby(
      name: name,
      description: description,
      topic: topicIndex,
    );

    return "";
  }

  /// Function called when the user is in a lobbyDetailsView and want to join the lobby
  /// If the passed username is equal to null or the saving procedure fail, the function return false.
  /// If everything goes fine, the function return true.
  Future<bool> didTapOnJoinLobbyButton(
      {String lobbyName, String username}) async {
    if (username == null) return false;
    await firestoreWrapper.addUserToLobby(
        lobbyName: lobbyName, username: username);
    return true;
  }

  /// Function called when the user is in searchView and want to search for a
  /// specific lobby. The function will search the lobby corresponding to
  /// the passed name
  Future<List<Lobby>> didTapOnSearchButton({String nameKeyword}) async {
    if (nameKeyword.startsWith('@')) {
      String topicName = nameKeyword.replaceFirst("@", "");
      if (topicName == "" || topicName == null) return null;
      Topics topic = TopicsHelper.fromString(topicName);
      if (topic == null) return null;

      List<QueryDocumentSnapshot<Object>> docs =
          await firestoreWrapper.getTrendLobbiesWithTopic(topic.toInt());
      return docs.map((doc) => Lobby.fromMap(doc.data(), id: doc.id)).toList();
    } else {
      if (nameKeyword == "" || nameKeyword == null) return null;
      List<QueryDocumentSnapshot<Object>> docs =
          await firestoreWrapper.getTrendLobbiesWithNameContaining(nameKeyword);

      return docs.map((doc) => Lobby.fromMap(doc.data(), id: doc.id)).toList();
    }
  }

  /// Function called when the user is in lobby info view and want to
  /// leave the specified lobby
  Future<bool> didTapOnLeaveLobby({String lobbyName, String username}) async {
    if (lobbyName == null || lobbyName == "") return false;
    if (username == null || username == "") return false;

    await firestoreWrapper.removeUserToLobby(
      lobbyName: lobbyName,
      username: username,
    );
    return true;
  }

  /// Function called when the user is in searchView and do not insert any
  /// search criteria
  Future<List<Lobby>> getTrendLobbies() async {
    List<QueryDocumentSnapshot<Object>> docs =
        await firestoreWrapper.getTrendLobbies();
    return docs.map((doc) => Lobby.fromMap(doc.data(), id: doc.id)).toList();
  }

  /// Function called when the user press on a lobby in the search view
  /// to return the most updated lobby data
  Future<Lobby> getLobbyWithId(String id) async {
    DocumentSnapshot<Object> doc = await firestoreWrapper.getLobbiesWithId(id);
    if (doc.exists) {
      return Lobby.fromMap(doc.data(), id: doc.id);
    } else
      return null;
  }
}
