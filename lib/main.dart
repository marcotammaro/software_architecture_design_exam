import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/app_launcher.dart';
import 'package:forat/bloc/lobbies_bloc.dart';
import 'package:forat/bloc/messages_bloc.dart';
import 'package:forat/views/login_view.dart';
import 'package:forat/views/registraton_view.dart';

import 'firebase_wrappers/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      child: MyApp(),
      providers: [
        BlocProvider<LobbiesBloc>(
          create: (BuildContext context) => LobbiesBloc(),
        ),
        BlocProvider<MessagesBloc>(
          create: (BuildContext context) => MessagesBloc(),
        ),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1DA6FB),
        unselectedWidgetColor: Color(0xFFB9BDC2),
        backgroundColor: Color(0xFFFFFFFF),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Color(0xFF0F1546),
              displayColor: Color(0xFF0F1546),
            ),
      ),
      home: LoginView(),
    );
  }
}
