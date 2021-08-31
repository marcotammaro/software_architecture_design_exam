import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forat/models/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/views/lobbies_view.dart';
import 'package:forat/views/login_view.dart';
import 'package:forat/views/profile_view.dart';
import 'package:forat/views/search_view.dart';

class AppLauncher extends StatefulWidget {
  @override
  _AppLauncherState createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  int _currentIndex = 0;

  var _items = [
    BottomNavigationBarItem(
      label: "Lobbies",
      icon: Icon(FontAwesomeIcons.archive),
    ),
    BottomNavigationBarItem(
      label: "Search",
      icon: Icon(FontAwesomeIcons.search),
    ),
    BottomNavigationBarItem(
      label: "Profile",
      icon: Icon(FontAwesomeIcons.userAlt),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (AuthWrapper.instance.getCurrentUsername() == "" ||
        AuthWrapper.instance.getCurrentUserEmail() == "") {
      return LoginView();
    }
    return Scaffold(
      body: _getCurrentBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _getCurrentBody(int index) {
    switch (index) {
      case 0:
        return LobbiesView();
      case 1:
        return SearchView();
      case 2:
        return ProfileView();
      default:
        return Container();
    }
  }
}
