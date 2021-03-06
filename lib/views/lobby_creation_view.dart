import 'package:flutter/material.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/models/topics.dart';
import 'package:forat/utility/show_error_alert.dart';

class LobbyCreationView extends StatefulWidget {
  @override
  _LobbyCreationViewState createState() => _LobbyCreationViewState();
}

class _LobbyCreationViewState extends State<LobbyCreationView> {
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  int _selectedChip;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Theme.of(context).backgroundColor,
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
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            child: Text(
              "Save",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 16),
            ),
            onPressed: onSave,
          ),
        ],
        title: Text(
          'Lobby Creation',
          style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
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
            BoxShadow(
                color: Theme.of(context).unselectedWidgetColor.withAlpha(100),
                blurRadius: 10)
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
    Topics topic = TopicsHelper.fromInt(index);
    Color chipColor = topic.color();
    String title = topic.name();

    return GestureDetector(
      onTap: () => setState(() => _selectedChip = index),
      child: Chip(
        elevation: 1,
        backgroundColor: chipColor,
        label: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1.color,
            fontWeight:
                _selectedChip == index ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // MARK: User Actions

  void onSave() async {
    String error = await LobbyLogic(context).didTapOnCreateLobbyButton(
      name: _nameController.text,
      description: _descriptionController.text,
      topicIndex: _selectedChip,
    );
    if (error == "") {
      Navigator.pop(context);
    } else {
      showErrorAlert(context, message: error);
    }
  }
}
