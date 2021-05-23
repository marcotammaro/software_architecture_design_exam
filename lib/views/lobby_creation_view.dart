import 'package:flutter/material.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/models/topics.dart';

class LobbyCreationView extends StatefulWidget {
  @override
  _LobbyCreationViewState createState() => _LobbyCreationViewState();
}

class _LobbyCreationViewState extends State<LobbyCreationView> {
  LobbyLogic _controller;
  final List<Color> clipColors = [
    Colors.red[300],
    Colors.blue[300],
    Colors.yellow[300],
    Colors.green[300],
    Colors.teal[300],
    Colors.purple[300],
    Colors.brown[300]
  ];

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  int _selectedChip;

  @override
  void initState() {
    super.initState();
    _controller = LobbyLogic(context);
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedChip = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            nameTextField(),
            descriptionTextField(),
            topicChips(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MARK: Widgets

  Widget appBar() => AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            child: Text(
              "Save",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            onPressed: onSave,
          ),
        ],
        title: Text(
          'Lobby Creation',
          style: TextStyle(color: Colors.black),
        ),
      );

  Widget nameTextField() => textFieldBox(
        title: "Name",
        child: TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Insert the lobby name",
          ),
        ),
      );

  Widget descriptionTextField() => textFieldBox(
        title: "Description",
        child: TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Insert the lobby description",
          ),
        ),
      );

  Widget topicChips() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List.generate(
            Topics.values.length,
            (index) => topicButton(index),
          ),
        ),
      );

  // MARK: Utility Widget Functions

  Widget textFieldBox({String title, Widget child}) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withAlpha(100), blurRadius: 10)
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Align(alignment: Alignment.bottomLeft, child: child),
          ],
        ),
      );

  Widget topicButton(int index) {
    Color chipColor = clipColors[index % clipColors.length].withAlpha(100);
    String title = Topics.values[index].toString().split('.').last;

    return GestureDetector(
      onTap: () => setState(() => _selectedChip = index),
      child: Chip(
        elevation: 1,
        backgroundColor: chipColor,
        label: Text(
          title,
          style: TextStyle(
            fontWeight:
                _selectedChip == index ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // MARK: User Actions

  void onSave() {
    _controller.didTapOnCreateLobbyButton(
      name: _nameController.text,
      description: _descriptionController.text,
      topic: TopicsHelper.fromInt(_selectedChip),
    );
  }
}
