import 'package:flutter/material.dart';
import 'package:forat/logic/account_logic.dart';

class RegistrationView extends StatefulWidget {
  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final _dateController = TextEditingController();
  AccountLogic _accountLogic;
  final _textFieldControllerEmail = TextEditingController();
  final _textFieldControllerUsername = TextEditingController();
  final _textFieldControllerPassword = TextEditingController();
  final _textFieldControllerConfirmPassword = TextEditingController();
  var date;
  @override
  void initState() {
    super.initState();
    _accountLogic = AccountLogic(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 120.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image(
                  image: AssetImage("images/logo.png"),
                  alignment: Alignment.center,
                ),
                SizedBox(height: 30.0),
                emailTextField(),
                SizedBox(height: 30.0),
                usernameTextField(),
                SizedBox(height: 30.0),
                birthTextField(),
                SizedBox(height: 30.0),
                passwordTextField(),
                SizedBox(height: 30.0),
                confirmPasswordTextField(),
                registerButton(),
                signInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: Widgets

  Widget emailTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 60.0,
      child: TextField(
        controller: _textFieldControllerEmail,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14.0),
          prefixIcon: Icon(
            Icons.email,
            color: Colors.white,
          ),
          hintText: 'Email',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget usernameTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 60.0,
      child: TextField(
        controller: _textFieldControllerUsername,
        keyboardType: TextInputType.name,
        style: TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14.0),
          prefixIcon: Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
          ),
          hintText: 'Username',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget birthTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 60.0,
      child: TextField(
        readOnly: true,
        controller: _dateController,
        onTap: () async {
          date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100));
          if (date != null) {
            _dateController.text = date.toString().substring(0, 10);
          }
        },
        style: TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14.0),
          prefixIcon: Icon(
            Icons.date_range_outlined,
            color: Colors.white,
          ),
          hintText: 'Date of Birth',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget passwordTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: _textFieldControllerPassword,
            obscureText: true,
            style: TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget confirmPasswordTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 60.0,
      child: TextField(
        controller: _textFieldControllerConfirmPassword,
        obscureText: true,
        style: TextStyle(color: Colors.white, fontFamily: 'OpenSans'),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14.0),
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          hintText: 'Confirm Password',
          hintStyle: TextStyle(
            color: Colors.white54,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget registerButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onRegister(),
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(5.0),
            padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0))),
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor)),
        child: Text(
          'REGISTER',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget signInButton() {
    return GestureDetector(
      onTap: () => _accountLogic.goToLoginView(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: 'Already have an Account? ',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                )),
            TextSpan(
              text: 'Login',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  // MARK: User Actions

  void onRegister() async {
    bool completed = await AccountLogic.didTapOnRegisterButton(
      context,
      email: _textFieldControllerEmail.text,
      password: _textFieldControllerPassword.text,
      confirmPassword: _textFieldControllerConfirmPassword.text,
      username: _textFieldControllerUsername.text,
      birthdate: date,
    );
    if (completed) {
      _accountLogic.goToLobbiesView();
    }
  }
}
