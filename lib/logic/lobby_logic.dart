import 'package:flutter/material.dart';
import 'package:forat/models/topics.dart';
import 'package:forat/models/user.dart';
import 'package:forat/utility/show_error_alert.dart';
import 'package:forat/views/lobby_creation_view.dart';
import 'package:forat/views/lobby_details_view.dart';

class LobbyLogic {
  BuildContext _context;

  // Constructor
  LobbyLogic(this._context);

  // MARK: Navigator Logic

  void goToLobbyCreationView() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => LobbyCreationView()),
    );
  }

  void goToLobbyDetailedView() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => LobbyDetailsView()),
    );
  }

  // MARK: Buttons Logic

  void didTapOnCreateLobbyButton({
    String name,
    String description,
    Topics topic,
  }) {
    // Checking if user choose a topic for the lobby
    if (topic == null) {
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

    // TODO: Check that name is unique
    // TODO: Create and save the new lobby

    Navigator.of(_context).pop();
  }

  void didTapOnJoinLobbyButton({String name, User user}) {}
  void didTapOnSearchButton() {}
}
