import 'package:flutter/material.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forat/logic/message_logic.dart';
import 'package:mockito/mockito.dart';

class MockFirestoreWrapper extends Mock implements FirestoreWrapper {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  MessageLogic controller;

  final MockFirestoreWrapper mockFirestoreWrapper = MockFirestoreWrapper();
  final MockBuildContext mockBuildContext = MockBuildContext();

  setUp(() {
    controller = MessageLogic(mockBuildContext, "Test", mockFirestoreWrapper);
  });

  group("Test didTapOnSendButton", () {
    when(mockFirestoreWrapper.getMessagesStream("Test"))
        .thenAnswer((realInvocation) async => null);
    test('Empty text', () async {
      bool returnValue = controller.didTapOnSendButton("");
      expect(returnValue, false);
    });

    test('Should pass', () async {
      bool returnValue = controller.didTapOnSendButton("Message text");
      expect(returnValue, true);
    });
  });
}
