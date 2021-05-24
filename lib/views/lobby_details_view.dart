import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/logic/message_logic.dart';
import 'package:forat/models/message.dart';

class LobbyDetailsView extends StatefulWidget {
  @override
  _LobbyDetailsViewState createState() => _LobbyDetailsViewState();
}

class _LobbyDetailsViewState extends State<LobbyDetailsView> {
  bool _isButtonEnabled = true;
  MessageLogic _controller;
  ScrollController _scrollController;
  final myController = TextEditingController();
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), primary: Colors.red);
  @override
  void initState() {
    super.initState();
    _controller = MessageLogic(context);
    _scrollController = ScrollController();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      moveListToEnd();
    });
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red),
      backgroundColor: Colors.green,
      body: BlocBuilder<MessagesBloc, List<Message>>(
          builder: (context, messages) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (messages[index].creator.username ==
                              "MODIFICA" //TODO: DEVI MODIFICARE E AGGIUNGERE == ALL UTENTE DELL APP
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (messages[index].creator.username ==
                                  "MODIFICA" //TODO : DEVI MODIFICARE E AGGIUNGERE == ALL UTENTE DELL APP
                              ? Colors.grey.shade200
                              : Colors.blue[200]),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(messages[index].creator.username,
                                style: TextStyle(fontSize: 10),
                                textAlign: TextAlign.left),
                            Text(
                              messages[index].text,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: (_isButtonEnabled == true) ? true : false,
              child: Container(
                height: 50,
                child: ElevatedButton(
                  style: style,
                  onPressed: () {
                    isButtonEnabled();
                  },
                  child: const Text('Enabled'),
                ),
              ),
              replacement: Container(
                height: 50,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.75,
                      color: Colors.white,
                      child: TextField(
                        controller: myController,
                        enabled: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter a search term'),
                      ),
                    ),
                    ElevatedButton(
                      style: style,
                      onPressed: () {
                        _controller.didTapOnSendButton(myController.text);
                        moveListToEnd();
                      },
                      child: const Text('Invia'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void moveListToEnd() {
    if (_scrollController.position.maxScrollExtent != null) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
    }
  }

  bool isButtonEnabled() {
    setState(() {});
    if (_isButtonEnabled == true) {
      _isButtonEnabled = false;

      return true;
    } else {
      _isButtonEnabled = true;

      return false;
    }
  }
}
