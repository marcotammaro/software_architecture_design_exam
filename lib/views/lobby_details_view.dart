import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/logic/message_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/message.dart';
import 'package:forat/models/topics.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class LobbyDetailsView extends StatefulWidget {
  final Lobby lobby;

  const LobbyDetailsView({Key key, @required this.lobby}) : super(key: key);
  @override
  _LobbyDetailsViewState createState() => _LobbyDetailsViewState();
}

class _LobbyDetailsViewState extends State<LobbyDetailsView> {
  MessageLogic _messagesController;
  bool _isButtonEnabled = true;
  int _keyboardListnerID;
  double _bottomBarHeight = 60;
  final _scrollController = ScrollController();
  final _keyboardVisibility = KeyboardVisibilityNotification();
  final _textFieldController = TextEditingController();
  ButtonStyle style;
  @override
  void initState() {
    super.initState();
    style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      primary: widget.lobby.topic.color(),
    );

    _messagesController = MessageLogic(context, widget.lobby.name);
    LobbyLogic.checkForUserJoined(lobby: widget.lobby).then((value) {
      setState(() => _isButtonEnabled = !value);
    });

    _keyboardListnerID = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        moveListToEnd();
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    _textFieldController.dispose();
    _messagesController.stopListenMessages();
    _keyboardVisibility.removeListener(_keyboardListnerID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(widget.lobby.name),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 1,
      ),
      body: BlocBuilder<MessagesBloc, List<Message>>(
        builder: (context, messages) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(child: listViewMessage(messages)),
                bottomTab(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Visibility bottomTab(BuildContext context) {
    return Visibility(
      visible: (_isButtonEnabled) ? true : false,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        height: _bottomBarHeight,
        width: MediaQuery.of(context).size.width * 0.8,
        child: ElevatedButton(
          style: style,
          onPressed: () {
            LobbyLogic.didTapOnJoinLobbyButton(
                    lobbyName: widget.lobby.name,
                    username: AuthWrapper.instance.getCurrentUsername())
                .then(
              (value) => setState(() => _isButtonEnabled = !value),
            );
          },
          child: const Text('Join Chat!'),
        ),
      ),
      replacement: Container(
        height: _bottomBarHeight,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: _bottomBarHeight,
              width: MediaQuery.of(context).size.width * 0.65,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).unselectedWidgetColor.withAlpha(100),
                    blurRadius: 10,
                  )
                ],
              ),
              padding: EdgeInsets.only(left: 15),
              child: TextField(
                controller: _textFieldController,
                enabled: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a message',
                ),
              ),
            ),
            ElevatedButton(
              style: style,
              onPressed: () {
                _messagesController
                    .didTapOnSendButton(_textFieldController.text);
                _textFieldController.clear();
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  ListView listViewMessage(List<Message> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveListToEnd();
    });
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: messages.length,
      shrinkWrap: true,
      // physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Align(
            alignment: (messages[index].username !=
                    AuthWrapper.instance.getCurrentUsername()
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (messages[index].username !=
                        AuthWrapper.instance.getCurrentUsername()
                    ? Colors.grey.shade200
                    : widget.lobby.topic.color()),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(messages[index].username,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.left),
                  SizedBox(height: 5),
                  Text(messages[index].text,
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.left),
                  SizedBox(height: 5),
                  Text(
                      "${messages[index].dateTime.hour}:${messages[index].dateTime.minute}",
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void moveListToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent +
          _bottomBarHeight +
          MediaQuery.of(context).viewInsets.bottom,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }
}
