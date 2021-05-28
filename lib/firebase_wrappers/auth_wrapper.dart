import 'package:firebase_auth/firebase_auth.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';

class AuthWrapper {
  // MARK: Singleton management
  static final AuthWrapper _singleton = AuthWrapper._();
  static AuthWrapper get instance => _singleton;
  AuthWrapper._();

  // MARK: Attributes
  FirebaseAuth _auth = FirebaseAuth.instance;

  // MARK: Functions

  /// This function create a new account with firebase auth and add the username as displayName to the created account.
  /// If an error occur, it will return a FirebaseAuthException otherwise it will return null
  Future<FirebaseAuthException> createUser({
    String username,
    String email,
    String password,
  }) async {
    try {
      bool exist =
          await FirestoreWrapper.instance.checkForUsername(username: username);

      if (exist)
        return FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'username already taken',
        );

      // Creating firebase auth account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      userCredential.user.updateProfile(displayName: username);

      // No exception
      return null;
    } catch (e) {
      return e;
    }
  }

  /// Return the username of the logged user as a string.
  /// If no current user is logged in, the function return an empty string
  String getCurrentUsername() {
    if (FirebaseAuth.instance.currentUser == null) return "";
    return FirebaseAuth.instance.currentUser.displayName;
  }

  /// This function login an existing user with firebase auth.
  /// If an error occur, it will return a FirebaseAuthException otherwise it will return null
  Future<FirebaseAuthException> loginUser(
      {String email, String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // No exception
      return null;
    } catch (e) {
      return e;
    }
  }

  /// This function logout the current user.
  void logoutUser() async {
    await _auth.signOut();
  }
}
