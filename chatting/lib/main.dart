import 'package:chatting/auth_provider.dart';
import 'package:chatting/chat_provider.dart';
import 'package:chatting/home_screen.dart';
import 'package:chatting/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:chatting/firebase_options.dart';
import 'package:provider/provider.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_)=> Authprovider()),
      ChangeNotifierProvider(create: (_)=> ChatProvider()),
    ],


    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home:AuthenticationWrapper(),
    ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Authprovider>(
      builder: (context,authProvider,child){
        if(authProvider.isSignedIn){
          return HomeScreen();
        }
        else {
          return LoginScreen();
        }
      },
      );
  }
}