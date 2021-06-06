import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/lobbies_event.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/topics.dart';
import 'package:forat/utility/show_error_alert.dart';
import 'package:forat/views/lobby_creation_view.dart';
import 'package:forat/views/lobby_details_view.dart';

class LobbyLogic {
  // Class Attributes
  BuildContext _streamContext;
  StreamSubscription<QuerySnapshot> _stream;

  // Constructor
  LobbyLogic(this._streamContext) {
    startListenLobbies();
  }

  // MARK: Utility Functions

  /// This function will start listening for lobbies snapshot on firebase
  void startListenLobbies() {
    FirestoreWrapper.instance.getUserLobbiesStream().then((value) {
      _stream = value.listen(onLobbiesEvent);
    });
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
    _stream.cancel();
  }

  /// Return true if user have lobbies
  Future<bool> userHaveLobbies() async {
    bool userHasLobbies = await FirestoreWrapper.instance.checkForUserLobbies();
    return userHasLobbies;
  }

  /// This function return true if the current user has logged in into the
  /// passed lobby; false otherwise
  static Future<bool> checkForUserJoined({Lobby lobby}) async {
    return lobby.users.contains(AuthWrapper.instance.getCurrentUsername());
  }

  // MARK: Navigator Logic

  void goToLobbyCreationView() async {
    Navigator.push(
      _streamContext,
      MaterialPageRoute(builder: (_context) => LobbyCreationView()),
    );
  }

  static void goToLobbyDetailedView(BuildContext context, Lobby lobby) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_context) => LobbyDetailsView(lobby: lobby)),
    );
  }

  // MARK: Buttons Logic

  /// Function called when the user is in the LobbyCreationView and user tap on save button.
  /// This function will check for correct topicIndex and name; if some fields are incorrect, it will return false and show an error screen.
  /// If everything is fine, it will add the lobby to firestore and will return true once all operation have completed.
  static Future<bool> didTapOnCreateLobbyButton(
    BuildContext context, {
    String name,
    String description,
    int topicIndex,
  }) async {
    // Checking if user choose a topic for the lobby
    if (topicIndex == null) {
      showErrorAlert(
        context,
        message: "Please, select a topic.",
      );
      return false;
    }
    // Checking if user choose a name for the lobby
    if (name == null || name == "") {
      showErrorAlert(
        context,
        message: "Please, insert a name.",
      );
      return false;
    }

    // checking for unique lobby name
    bool alreadyExist = await FirestoreWrapper.instance
        .checkForUniqueLobbyName(lobbyName: name);

    // douplicated lobby name => show error
    if (alreadyExist) {
      showErrorAlert(
        context,
        message: "The name of the lobby already exist",
      );
      return false;
    }

    await FirestoreWrapper.instance.addLobby(
      name: name,
      description: description,
      topic: topicIndex,
    );

    return true;
  }

  /// Function called when the user is in a lobbyDetailsView and want to join the lobby
  /// If the passed username is equal to null or the saving procedure fail, the function return false.
  /// If everything goes fine, the function return true.
  static Future<bool> didTapOnJoinLobbyButton(
      {String lobbyName, String username}) async {
    if (username == null) return false;
    await FirestoreWrapper.instance
        .addUserToLobby(lobbyName: lobbyName, username: username);
    return true;
  }

  /// Function called when the user is in searchView and want to search for a
  /// specific lobby. The function will search the lobby corresponding to
  /// the passed name
  static Future<List<Lobby>> didTapOnSearchButton(BuildContext context,
      {String nameKeyword}) async {
    if (nameKeyword.startsWith('@')) {
      String topicName = nameKeyword.replaceFirst("@", "");
      Topics topic = TopicsHelper.fromString(topicName);
      if (topic == null) {
        showErrorAlert(
          context,
          message: "No topics found with the inserted name",
        );
        return null;
      }

      List<QueryDocumentSnapshot<Object>> docs = await FirestoreWrapper.instance
          .getTrendLobbiesWithTopic(topic.toInt());
      return docs.map((doc) => Lobby.fromMap(doc.data(), id: doc.id)).toList();
    } else {
      List<QueryDocumentSnapshot<Object>> docs = await FirestoreWrapper.instance
          .getTrendLobbiesWithNameContaining(nameKeyword);

      return docs.map((doc) => Lobby.fromMap(doc.data(), id: doc.id)).toList();
    }
  }

  /// Function called when the user is in searchView and do not insert any
  /// search criteria
  static Future<List<Lobby>> getTrendLobbies() async {
    List<QueryDocumentSnapshot<Object>> docs =
        await FirestoreWrapper.instance.getTrendLobbies();
    List<Lobby> lobbies = [];
    for (var doc in docs) {
      lobbies.add(Lobby.fromMap(doc.data(), id: doc.id));
    }
    return lobbies;
  }
}
