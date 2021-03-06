import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SetMasterPassword.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;
  Color selectedColor = Colors.red;

  openSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey('primaryColor')) {
        selectedColor = Color(prefs.getInt('primaryColor')!);
        return;
      }
      selectedColor = const Color(0xff5153FF);
    });
  }

  @override
  void initState() {
    openSharedPreferences();
    super.initState();
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  late Color pickedColor;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      key: scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                margin: EdgeInsets.only(top: size.height * 0.05),
                child: Text("Settings",
                    style: TextStyle(
                        fontFamily: "Title",
                        fontSize: 32,
                        color: primaryColor))),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const SetMasterPassword()));
            },
            child: const ListTile(
              title: Text(
                "Master Password",
                style: TextStyle(
                  fontFamily: 'Title',
                ),
              ),
              subtitle: Text(
                "Change your Master Password",
                style: TextStyle(
                  fontFamily: 'Subtitle',
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              const ListTile(
                title: Text(
                  "Accent Color",
                  style: TextStyle(
                    fontFamily: 'Title',
                  ),
                ),
                subtitle: Text(
                  "Change Accent Color",
                  style: TextStyle(
                    fontFamily: 'Subtitle',
                  ),
                ),
              ),
              MaterialColorPicker(
                onColorChange: (Color color) {
                  pickedColor = color;
                  changeColor(color);
                  setState(() {
                    selectedColor = color;
                  });
                },
                circleSize: 60,
                selectedColor: selectedColor,
              ),
            ],
          )
        ],
      ),
    );
  }

  void changeColor(Color color) {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('primaryColor', color.value);
  }
}
