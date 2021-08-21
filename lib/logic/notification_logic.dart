import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forat/firebase_wrappers/firestore_wrapper.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/message.dart' as message;
import 'package:forat/models/notification.dart';

class NotificationLogic {
  // Singleton management
  static final NotificationLogic _singleton = NotificationLogic._();
  static NotificationLogic get instance => _singleton;
  NotificationLogic._();

  // Class Attributes
  StreamSubscription<QuerySnapshot> _stream;
  Map<String, message.Message> _history;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _isInitializing = true;
  String _unlistenedLobby;

  // MARK: Utility Functions

  /// Should be called once the app start in order to start listenings for incoming messages
  void start() async {
    _history = Map<String, message.Message>();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializePlatformSpecifics();
    _requestIOSPermissions();

    // start listen for lobbies
    FirestoreWrapper.instance.getUserLobbiesStream().then((value) {
      _stream = value.listen(_onLobbiesEvent);
    });
  }

  /// Function to stop listening from lobbies snapshot
  /// Should be called once the user log out
  void stop() {
    if (_stream != null) _stream.cancel();
    if (flutterLocalNotificationsPlugin != null)
      flutterLocalNotificationsPlugin.cancelAll();
    _isInitializing = true;
  }

  /// Function to not show notification of the specified lobby
  void stopListenForLobby(String key) {
    _unlistenedLobby = key;
  }

  /// Function to show again notification of the lobby passed to stopListenForLobby
  void removeStopListenForLobby() {
    _unlistenedLobby = null;
  }

  /// Function to reset the _isInitializing propriety to not show notification on lobbies_view loading
  void resetIsInitializing() {
    _isInitializing = true;
  }

  /// Function required to initialize the notification plugin specifics
  void _initializePlatformSpecifics() async {
    var initializationAndroidSettings =
        AndroidInitializationSettings('notification_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
      // setting this values to false in order to ask for ios permission later and not at init time
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // your call back to the UI when user tap on a notification
      },
    );

    var initializationSettings = InitializationSettings(
      android: initializationAndroidSettings,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        // your call back to the UI when user tap on a notification
      },
    );
  }

  /// Function required to request ios permissions for notifications
  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Function to show a notification
  Future _scheduleInstantNotification({
    Notification notification,
  }) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      "CHANNEL_ID_NMA",
      "New message alert",
      "",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(
      notification.key,
      notification.title,
      notification.text,
      platformChannelSpecifics,
    );
  }

  /// Callback called when the lobbies snapshot updates
  void _onLobbiesEvent(QuerySnapshot<Object> event) async {
    // Removing all previous lobbies from the bloc
    List<Lobby> newLobbies = [];
    for (var doc in event.docs) {
      var lobby = Lobby.fromMap(doc.data(), id: doc.id);
      newLobbies.add(lobby);
    }

    for (Lobby newLobby in newLobbies) {
      if ((_history.containsKey(newLobby.key) &&
              _history[newLobby.key].text != newLobby.lastMessage.text) ||
          (_history.containsKey(newLobby.key) == false)) {
        // Creating notification
        Notification notification = Notification(
          key: Random().nextInt(9999), // 2^32 is max value usable as key
          from: newLobby.lastMessage.username ?? "unknow",
          text:
              "${newLobby.lastMessage.username}: ${newLobby.lastMessage.text}",
          title: newLobby.name,
          datetime: DateTime.now(),
        );

        // Scheduling notification
        if (!_isInitializing && newLobby.key != _unlistenedLobby)
          _scheduleInstantNotification(notification: notification);

        // Updating history
        _history[newLobby.key] = newLobby.lastMessage;
      }
    }

    _isInitializing = false;
  }
}
