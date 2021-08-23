import 'package:flutter/material.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreWrapper extends Mock implements FirestoreWrapper {}

class MockAuthWrapper extends Mock implements AuthWrapper {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  LobbyLogic controller;

  final MockFirestoreWrapper mockFirestoreWrapper = MockFirestoreWrapper();
  final MockAuthWrapper mockAuthWrapper = MockAuthWrapper();
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUp(() {
    controller =
        LobbyLogic(mockBuildContext, mockAuthWrapper, mockFirestoreWrapper);
  });

  group("Test didTapOnCreateLobbyButton", () {
    test('Empty topic', () async {
      String returnValue = await controller.didTapOnCreateLobbyButton(
        name: "",
        description: "",
        topicIndex: null,
      );
      expect(returnValue, "Please, select a topic.");
    });

    test('Empty name', () async {
      String returnValue = await controller.didTapOnCreateLobbyButton(
        name: "",
        description: "",
        topicIndex: 1,
      );
      expect(returnValue, "Please, insert a name.");
    });

    test('Not unique name', () async {
      when(mockFirestoreWrapper.checkForUniqueLobbyName(lobbyName: "Test"))
          .thenAnswer((realInvocation) async => true);
      String returnValue = await controller.didTapOnCreateLobbyButton(
        name: "Test",
        description: "",
        topicIndex: 1,
      );
      expect(returnValue, "The name of the lobby already exist");
    });

    test('Should pass', () async {
      when(mockFirestoreWrapper.checkForUniqueLobbyName(lobbyName: "Test"))
          .thenAnswer((realInvocation) async => false);

      when(mockFirestoreWrapper.addLobby(
        name: "Test",
        description: "",
        topic: 1,
      )).thenAnswer((realInvocation) => null);

      String returnValue = await controller.didTapOnCreateLobbyButton(
        name: "Test",
        description: "",
        topicIndex: 1,
      );
      expect(returnValue, "");
    });
  });

  group('Test didTapOnJoinLobbyButton', () {
    test('Empty username', () async {
      bool returnValue = await controller.didTapOnJoinLobbyButton(
          lobbyName: "Test", username: null);
      expect(returnValue, false);
    });

    test('Should pass', () async {
      when(mockFirestoreWrapper.addUserToLobby(
              lobbyName: "Test", username: "Bob"))
          .thenAnswer((realInvocation) => null);
      bool returnValue = await controller.didTapOnJoinLobbyButton(
          lobbyName: "Test", username: "Bob");
      expect(returnValue, true);
    });
  });

  group('Test didTapOnSearchButton', () {
    test('Empty nameKeyword', () async {
      List returnValue = await controller.didTapOnSearchButton(nameKeyword: "");
      expect(returnValue, null);
    });

    test('Empty topic', () async {
      List returnValue =
          await controller.didTapOnSearchButton(nameKeyword: "@");
      expect(returnValue, null);
    });

    test('Invalid topic', () async {
      List returnValue =
          await controller.didTapOnSearchButton(nameKeyword: "@NotATopic");
      expect(returnValue, null);
    });

    test('Should pass', () async {
      when(mockFirestoreWrapper.getTrendLobbiesWithTopic(0))
          .thenAnswer((realInvocation) async => []);
      when(mockFirestoreWrapper.getTrendLobbiesWithNameContaining("keyword"))
          .thenAnswer((realInvocation) async => []);

      List returnValue =
          await controller.didTapOnSearchButton(nameKeyword: "@football");
      expect(returnValue, []);
      List secondReturnValue =
          await controller.didTapOnSearchButton(nameKeyword: "keyword");
      expect(secondReturnValue, []);
    });
  });

  group('Test didTapOnLeaveLobby', () {
    test('Empty lobbyName', () async {
      bool returnValue = await controller.didTapOnLeaveLobby(lobbyName: "");
      expect(returnValue, false);
    });

    test('Empty username', () async {
      bool returnValue =
          await controller.didTapOnLeaveLobby(lobbyName: "Test", username: "");
      expect(returnValue, false);
    });

    test('Should pass', () async {
      when(mockFirestoreWrapper.removeUserToLobby(
              lobbyName: "Test", username: "Test"))
          .thenAnswer((realInvocation) => null);

      bool returnValue = await controller.didTapOnLeaveLobby(
          lobbyName: "Test", username: "Test");
      expect(returnValue, true);
    });
  });
}
