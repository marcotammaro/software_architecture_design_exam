import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/lobbies_event.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/message.dart';
import 'package:forat/models/topics.dart';
import 'package:forat/utility/show_error_alert.dart';
import 'package:forat/views/lobby_creation_view.dart';
import 'package:forat/views/lobby_details_view.dart';

class LobbyLogic {
  // Class Attributes
  BuildContext _context;
  StreamSubscription<QuerySnapshot> _stream;

  // Constructor
  LobbyLogic(this._context) {
    startListenLobbies();
  }

  // MARL: Utility Functions

  /// This function will start listening for lobbies snapshot on firebase
  void startListenLobbies() {
    FirestoreWrapper.instance.getUserLobbiesStream().then((value) {
      _stream = value.listen(onLobbiesEvent);
    });
  }

  /// Callback called when the lobbies snapshot updates
  void onLobbiesEvent(QuerySnapshot<Object> event) async {
    // Removing all previous lobbies from the bloc
    BlocProvider.of<LobbiesBloc>(_context).add(LobbiesEvent.deleteAll());
    for (var doc in event.docs) {
      var lobby = Lobby.withKey(
        key: doc.id,
        name: doc.get('name'),
        description: doc.get('description'),
        topic: TopicsHelper.fromInt(doc.get('topic')),
        users: List<String>.from(doc.get('users')),
        lastMessage: Message(
          text: doc.get('lastMessage'),
          dateTime: DateTime.fromMillisecondsSinceEpoch(
            doc.get('lastMessageTimestamp'),
          ),
        ),
      );
      BlocProvider.of<LobbiesBloc>(_context).add(LobbiesEvent.add(lobby));
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

  // MARK: Navigator Logic

  void goToLobbyCreationView() async {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => LobbyCreationView()),
    );
  }

  void goToLobbyDetailedView(Lobby lobby) {
    Navigator.push(
      _context,
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

  static Future<bool> checkForUserJoined({Lobby lobby}) async {
    return lobby.users.contains(AuthWrapper.instance.getCurrentUsername());
  }

  void didTapOnSearchButton() {
    // TODO
  }
}
