import 'package:flutter/material.dart';
import 'package:forat/firebase_wrappers/auth_wrapper.dart';
import 'package:forat/logic/account_logic.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: appBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              infoCell(),
              logoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: Widgets

  Widget appBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        "Profile",
        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget infoCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "Current user",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).unselectedWidgetColor.withAlpha(100),
                  blurRadius: 10,
                )
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  AuthWrapper.instance.getCurrentUserEmail(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 20),
                Text(
                  "Username",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  AuthWrapper.instance.getCurrentUsername(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget logoutButton() {
    return MaterialButton(
      onPressed: onLogout,
      color: Theme.of(context).primaryColor,
      textColor: Theme.of(context).backgroundColor,
      child: Text("Log Out"),
      padding: EdgeInsets.all(12),
      minWidth: 200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }

  // MARK: User Actions

  void onLogout() {
    AuthWrapper.instance.logoutUser();
    AccountLogic(context).goToLoginView();
    //TODO to test
  }
}
