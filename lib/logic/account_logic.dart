import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/views/lobbies_view.dart';
import 'package:forat/views/login_view.dart';
import 'package:forat/views/registraton_view.dart';

class AccountLogic {
  // Class Attributes
  BuildContext _context;

  // Constructor
  AccountLogic(this._context);

  // MARK: Navigator Logic

  void goToLobbiesView() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => LobbiesView()),
    );
  }

  void goToRegisterView() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => RegistrationView()),
    );
  }

  void goToLoginView() {
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (_context) => LoginView()),
    );
  }

  // MARK: Buttons Logic

  void didTapOnRegisterButton({
    String username,
    String email,
    String password,
    DateTime birthdate,
  }) async {
    //TODO: Check if age > 18

    FirebaseAuthException exception = await AuthWrapper.instance
        .createUser(username: username, email: email, password: password);

    if (exception != null) {
      //TODO: Manage error
      return;
    }

    // No exception occured

    // Creating document on firestore
    await FirestoreWrapper.instance.addUser(username: username);
  }

  void didTapOnLoginAccountButton({
    String email,
    String password,
  }) async {
    FirebaseAuthException exception =
        await AuthWrapper.instance.loginUser(email: email, password: password);

    if (exception != null) {
      //TODO: Manage error
      return;
    }
  }
}
