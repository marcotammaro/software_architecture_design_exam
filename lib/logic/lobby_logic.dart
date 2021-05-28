import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/events/lobbies_event.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
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

  // Constructor
  LobbyLogic(this._context) {
    _loadLobby();
  }

  // MARL: Utility Functions

  /// This function will get all the lobbies form firestore wrapper and
  /// add them to the bloc
  void _loadLobby() {
    // Getting lobbies from firestore wrapper
    FirestoreWrapper.instance.getUserLobbies().then((lobbies) async {
      // Removing all previous lobbies from the bloc
      BlocProvider.of<LobbiesBloc>(_context).add(LobbiesEvent.deleteAll());
      for (var lobby in lobbies) {
        BlocProvider.of<LobbiesBloc>(_context).add(LobbiesEvent.add(lobby));
      }
    });
  }

  // MARK: Navigator Logic

  void goToLobbyCreationView() {
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
  /// This function will check for correct topicIndex and name.
  /// If everything is fine, it will add the lobby to firestore
  Future didTapOnCreateLobbyButton({
    String name,
    String description,
    int topicIndex,
  }) async {
    // Checking if user choose a topic for the lobby
    if (topicIndex == null) {
      showErrorAlert(
        _context,
        message: "Please, select a topic.",
      );
      return;
    }
    // Checking if user choose a name for the lobby
    if (name == null || name == "") {
      showErrorAlert(
        _context,
        message: "Please, insert a name.",
      );
      return;
    }

    // checking for unique lobby name
    bool alreadyExist = await FirestoreWrapper.instance
        .checkForUniqueLobbyName(lobbyName: name);

    // douplicated lobby name => show error
    if (alreadyExist) {
      showErrorAlert(
        _context,
        message: "The name of the lobby already exist",
      );
      return;
    }

    // save lobby to firestore
    await FirestoreWrapper.instance.addLobby(
      name: name,
      description: description,
      topic: topicIndex,
    );

    // reload lobby data
    _loadLobby();

    // return to lobbiesView
    Navigator.of(_context).pop();
  }

  /// Function called when the user is in a lobbyDetailsView and want to join the lobby
  /// If the passed username is equal to null or the saving procedure fail, the function return false.
  /// If everything goes fine, the function return true.
  Future<bool> didTapOnJoinLobbyButton(
      {String lobbyName, String username}) async {
    if (username == null) return false;
    await FirestoreWrapper.instance
        .addUserToLobby(lobbyName: lobbyName, username: username);
    return true;
  }

  // TODO
  void didTapOnSearchButton() {}
  Future<bool> checkForUserJoined({String lobbyName}) async {
    return false;
  }
}
