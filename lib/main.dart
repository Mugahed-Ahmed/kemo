import 'package:flutter/material.dart';
import 'package:kemo/secrean/registration/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LevelDevilApp());
}

class LevelDevilApp extends StatelessWidget {
  const LevelDevilApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Level Devil',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'PixelFont',
      ),
      home: const LoginScreen(),
    );
  }
}
