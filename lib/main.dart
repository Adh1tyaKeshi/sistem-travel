import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistem_travel/screens/login_screen.dart';
import 'theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LuminaTravelApp());
}

class LuminaTravelApp extends StatelessWidget {
  const LuminaTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina Travel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
