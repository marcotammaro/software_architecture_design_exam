import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forat/logic/account_logic.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  AccountLogic _accountLogic;
  final _textFieldControllerEmail = TextEditingController();
  final _textFieldControllerPassword = TextEditingController();
  @override
  void initState() {
    super.initState();
    _accountLogic = AccountLogic(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
              Image(
                image: AssetImage("images/test.png"),
              ),
              SizedBox(height: 30.0),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Email',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        )),
                    SizedBox(height: 10.0),
                    Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Color(0xFF6CA8F1),
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
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'OpenSans'),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14.0),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              hintText: 'Enter your Email',
                              hintStyle: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'OpenSans',
                              )),
                        )),
                    SizedBox(height: 30.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Color(0xFF6CA8F1),
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
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'OpenSans'),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 14.0),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                    ),
                                    hintText: 'Enter your Password',
                                    hintStyle: TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'OpenSans',
                                    )),
                              )),
                        ]),
                    Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          onPressed: () =>
                              print('Forgot Password Button Pressed'),
                        )),
                  ]),
              Container(
                padding: EdgeInsets.symmetric(vertical: 25.0),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => loginFunction(),
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5.0),
                      padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _accountLogic.goToRegisterView(),
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Don\'t have an Account? ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      )),
                  TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ))
                ])),
              )
            ]),
          ),
        ),
      ),
    );
  }

  void loginFunction() async {
    bool completed = await AccountLogic.didTapOnLoginAccountButton(context,
        email: _textFieldControllerEmail.text,
        password: _textFieldControllerPassword.text);
    if (completed) {
      _accountLogic.goToLobbiesView();
    }
  }
}
