import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LobbiesView extends StatefulWidget {
  @override
  _LobbiesViewState createState() => _LobbiesViewState();
}

class _LobbiesViewState extends State<LobbiesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.plus,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
        title: Text(
          'Lobbies',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(color: Colors.red),
    );
  }
}
