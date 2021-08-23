import 'package:firebase_auth/firebase_auth.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/logic/account_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreWrapper extends Mock implements FirestoreWrapper {}

class MockAuthWrapper extends Mock implements AuthWrapper {}

void main() {
  AccountLogic controller;

  final MockFirestoreWrapper mockFirestoreWrapper = MockFirestoreWrapper();
  final MockAuthWrapper mockAuthWrapper = MockAuthWrapper();

  setUp(() {
    controller = AccountLogic(mockAuthWrapper, mockFirestoreWrapper);
  });

  group("Test didTapOnRegisterButton", () {
    test('Empty email', () async {
      String returnValue = await controller.didTapOnRegisterButton(email: "");
      expect(returnValue, "Please enter an email.");
    });

    test('Empty username', () async {
      String returnValue = await controller.didTapOnRegisterButton(
          email: "test@test.it", username: "");
      expect(returnValue, "Please enter an username.");
    });

    test('Empty birthdate', () async {
      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
      );
      expect(returnValue, "Please enter your birthdate.");
    });

    test('Empty password', () async {
      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
        birthdate: DateTime.now(),
        password: "",
      );
      expect(returnValue, "Please enter a password.");
    });

    test('Empty confirmPassword', () async {
      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
        birthdate: DateTime.now(),
        password: "1234",
        confirmPassword: "",
      );
      expect(returnValue, "Please confirm your password.");
    });

    test('Passwords match', () async {
      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
        birthdate: DateTime.now(),
        password: "1234",
        confirmPassword: "1243",
      );
      expect(returnValue, "Password doesn't match.");
    });

    test('Password length < 6', () async {
      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
        birthdate: DateTime.now(),
        password: "1234",
        confirmPassword: "1234",
      );
      expect(returnValue, "Password must have 6 characters.");
    });

    test('Age < 18', () async {
      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
        birthdate: DateTime.now(),
        password: "123456",
        confirmPassword: "123456",
      );
      expect(returnValue, "Your age is under 18.");
    });

    test('Invalid email', () async {
      when(
        mockAuthWrapper.createUser(
          username: "test1234",
          email: "test@it",
          password: "123456",
        ),
      ).thenAnswer((realInvocation) async {
        return FirebaseAuthException(
          code: "123",
          message: "Please insert a valid email.",
        );
      });

      when(mockFirestoreWrapper.addUser(username: "test1234"))
          .thenAnswer((realInvocation) => null);

      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@it",
        username: "test1234",
        birthdate: DateTime.now().subtract(const Duration(days: 6571)),
        password: "123456",
        confirmPassword: "123456",
      );
      expect(returnValue, "Please insert a valid email.");
    });

    test('Should pass', () async {
      when(
        mockAuthWrapper.createUser(
          username: "test1234",
          email: "test@it",
          password: "123456",
        ),
      ).thenAnswer((realInvocation) async {
        return null;
      });

      when(mockFirestoreWrapper.addUser(username: "test1234"))
          .thenAnswer((realInvocation) => null);

      String returnValue = await controller.didTapOnRegisterButton(
        email: "test@test.it",
        username: "test1234",
        birthdate: DateTime.now().subtract(const Duration(days: 6571)),
        password: "123456",
        confirmPassword: "123456",
      );
      expect(returnValue, "");
    });
  });

  group("Test didTapOnLoginAccountButton", () {
    test('Empty email', () async {
      String returnValue =
          await controller.didTapOnLoginAccountButton(email: "");
      expect(returnValue, "Please, insert an email.");
    });

    test('Empty password', () async {
      String returnValue = await controller.didTapOnLoginAccountButton(
          email: "test@test.it", password: "");
      expect(returnValue, "Please, insert password.");
    });

    test('Invalid credentials', () async {
      when(mockAuthWrapper.loginUser(email: "test@test.it", password: "123456"))
          .thenAnswer((realInvocation) async => FirebaseAuthException(
              code: "123", message: "Wrong Email or Password."));

      String returnValue = await controller.didTapOnLoginAccountButton(
          email: "test@test.it", password: "123456");
      expect(returnValue, "Wrong Email or Password.");
    });

    test('Should pass', () async {
      String returnValue = await controller.didTapOnLoginAccountButton(
          email: "test@test.it", password: "12345678");
      expect(returnValue, "");
    });
  });
}
