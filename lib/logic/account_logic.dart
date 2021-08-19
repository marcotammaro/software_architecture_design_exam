import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forat/app_launcher.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/utility/show_error_alert.dart';
import 'package:forat/views/login_view.dart';
import 'package:forat/views/registraton_view.dart';

class AccountLogic {
  // Class Attributes
  BuildContext _context;

  // Constructor
  AccountLogic(this._context);

  // MARK: Navigator Logic

  void goToLobbiesView() async {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => AppLauncher()),
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

  static Future<bool> didTapOnRegisterButton(
    BuildContext context, {
    String username,
    String email,
    String password,
    String confirmPassword,
    DateTime birthdate,
  }) async {
    //TODO: Check if age > 18
    print(birthdate);
    FirebaseAuthException exception = await AuthWrapper.instance
        .createUser(username: username, email: email, password: password);

    if (exception != null) {
      //TODO: Manage error
      return false;
    }

    // No exception occured

    // Creating document on firestore
    await FirestoreWrapper.instance.addUser(username: username);
    return true;
  }

  static Future<bool> didTapOnLoginAccountButton(
    BuildContext context, {
    String email,
    String password,
  }) async {
    if (email == "" || email == null) {
      showErrorAlert(
        context,
        message: "Please, insert an Email.",
      );
      return false;
    } else if (password == "" || password == null) {
      showErrorAlert(
        context,
        message: "Please, insert password.",
      );
      return false;
    } else {
      FirebaseAuthException exception = await AuthWrapper.instance
          .loginUser(email: email, password: password);

      if (exception != null) {
        //TO DO: exception

        showErrorAlert(
          context,
          message: "Wrong Email or Password.",
        );
        return false;
      }
      return true;
    }
  }
}
