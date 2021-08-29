import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forat/app_launcher.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/views/login_view.dart';
import 'package:forat/views/registraton_view.dart';

class AccountLogic {
  // Constructor
  AccountLogic([AuthWrapper _authWrapper, FirestoreWrapper _firestoreWrapper]) {
    this.authWrapper = _authWrapper ?? AuthWrapper.instance;
    this.firestoreWrapper = _firestoreWrapper ?? FirestoreWrapper.instance;
  }

  // MARK: Attributes
  AuthWrapper authWrapper;
  FirestoreWrapper firestoreWrapper;

  // MARK: Navigator Logic

  static void goToLobbiesView(BuildContext _context) async {
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (_context) => AppLauncher()),
    );
  }

  static void goToRegisterView(BuildContext _context) {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (_context) => RegistrationView()),
    );
  }

  static void goToLoginView(BuildContext _context) {
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (_context) => LoginView()),
    );
  }

  // MARK: Buttons Logic

  Future<String> didTapOnRegisterButton({
    String username,
    String email,
    String password,
    String confirmPassword,
    DateTime birthdate,
  }) async {
    if (email.isEmpty || email == "") return "Please enter an email.";
    if (username == null || username == "") return "Please enter an username.";
    if (birthdate == null) return "Please enter your birthdate.";
    if (password == null || password == "") return "Please enter a password.";
    if (confirmPassword == null || confirmPassword == "")
      return "Please confirm your password.";
    if (password != confirmPassword) return "Password doesn't match.";
    if (password.length < 6) return "Password must have 6 characters.";

    var verifyAge = birthdate.add(const Duration(days: 6570));

    if (DateTime.now().isBefore(verifyAge) == true) {
      return "Your age is under 18.";
    }

    FirebaseAuthException exception = await authWrapper.createUser(
      username: username,
      email: email,
      password: password,
    );

    if (exception != null) {
      return exception.message;
    }

    // No exception occured

    // Creating document on firestore
    await firestoreWrapper.addUser(username: username);
    return "";
  }

  Future<String> didTapOnLoginAccountButton({
    String email,
    String password,
  }) async {
    if (email == "" || email == null) {
      return "Please, insert an email.";
    } else if (password == "" || password == null) {
      return "Please, insert password.";
    } else {
      FirebaseAuthException exception =
          await authWrapper.loginUser(email: email, password: password);

      if (exception != null) {
        return exception.message;
      }
      return "";
    }
  }

  Future<String> didTapOnResetPassword({
    String email,
  }) async {
    if (email == "" || email == null) {
      return "Please, insert an email.";
    } else {
      FirebaseAuthException exception =
          await authWrapper.resetUserPassword(email);

      if (exception != null) {
        return exception.message;
      }
      return "";
    }
  }

  bool didTapOnLogoutButton() {
    authWrapper.logoutUser();
    return true;
  }
}
