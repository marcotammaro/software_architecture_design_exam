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
    Navigator.pushReplacement(
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
    if (email == null || email == "") {
      showErrorAlert(
        context,
        message: "Please enter an email.",
      );
      return false;
    }
    if (username == null || username == "") {
      showErrorAlert(
        context,
        message: "Please enter an username",
      );
      return false;
    }
    if (birthdate == null) {
      showErrorAlert(
        context,
        message: "Please enter your birthdate.",
      );
      return false;
    }
    if (password == null || password == "") {
      showErrorAlert(
        context,
        message: "Please enter a password.",
      );
      return false;
    }
    if (confirmPassword == null || confirmPassword == "") {
      showErrorAlert(
        context,
        message: "Please confirm your password.",
      );
      return false;
    }
    if (password != confirmPassword) {
      showErrorAlert(
        context,
        message: "Password doesn't match.",
      );
      return false;
    }
    if (password.length < 6) {
      showErrorAlert(
        context,
        message: "Password must have 6 characters.",
      );
      return false;
    }

    var verifyAge = birthdate.add(const Duration(days: 6570));

    if (DateTime.now().isBefore(verifyAge) == true) {
      showErrorAlert(
        context,
        message: "Your age is under 18.",
      );
      return false;
    }
    FirebaseAuthException exception = await AuthWrapper.instance
        .createUser(username: username, email: email, password: password);

    if (exception != null) {
      if (exception.code == "invalid-email") {
        showErrorAlert(
          context,
          message: "Please insert a valid email.",
        );
        return false;
      }
      if (exception.code == "email-already-in-use" ||
          exception.code == "username-already-in-use") {
        showErrorAlert(
          context,
          message: "Email or username already in use.",
        );
        return false;
      }
      showErrorAlert(
        context,
        message: "Something went wrong, try later.",
      );
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
