import 'pages/GreetingsPage.dart';
import 'pages/PasswordHomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int launch = 0;
  bool loading = true;
  late int primarycolorCode;
  Color primaryColor = const Color(0xff5153FF);

  checkPrimaryColr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    primarycolorCode = prefs.getInt('primaryColor') ?? 0;

    if (primarycolorCode != 0) {
      setState(() {
        primaryColor = Color(primarycolorCode);
      });
    }
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    launch = prefs.getInt("launch") ?? 0;

    const storage = FlutterSecureStorage();
    String masterPass = await storage.read(key: 'master') ?? '';

    if (prefs.getInt('primaryColor') == null) {
      await prefs.setInt('primaryColor', 0);
    }

    if (launch == 0 && masterPass == '') {
      await prefs.setInt('launch', launch + 1);
      await prefs.setInt('primaryColor', 0);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    checkPrimaryColr();
    checkFirstSeen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkPrimaryColr();
    ThemeData theme = ThemeData(
      fontFamily: "Title",
      primaryColor: primaryColor,
      accentColor: const Color(0xff0029cb),
      brightness: Brightness.light,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cipherly',
      theme: theme,
      home: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : launch == 0
              ? const GreetingsPage()
              : const PasswordHomepage(),
    );
  }
}
