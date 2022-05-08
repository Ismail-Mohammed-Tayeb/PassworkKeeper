import '../model/PasswordModel.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:developer';

class ViewPassword extends StatefulWidget {
  final Password password;

  const ViewPassword({Key? key, required this.password}) : super(key: key);

  @override
  _ViewPasswordState createState() => _ViewPasswordState();
}

class _ViewPasswordState extends State<ViewPassword> {
  TextEditingController masterPassController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();

  List<Icon> icons = const [
    Icon(Icons.account_circle, size: 64, color: Colors.white),
    Icon(Icons.add, size: 64, color: Colors.white),
    Icon(Icons.access_alarms, size: 64, color: Colors.white),
    Icon(Icons.ac_unit, size: 64, color: Colors.white),
    Icon(Icons.accessible, size: 64, color: Colors.white),
    Icon(Icons.account_balance, size: 64, color: Colors.white),
    Icon(Icons.add_circle_outline, size: 64, color: Colors.white),
    Icon(Icons.airline_seat_individual_suite, size: 64, color: Colors.white),
    Icon(Icons.arrow_drop_down_circle, size: 64, color: Colors.white),
    Icon(Icons.assessment, size: 64, color: Colors.white),
  ];

  List<String> iconNames = [
    "Icon 1",
    "Icon 2",
    "Icon 3",
    "Icon 4",
    "Icon 5",
    "Icon 6",
    "Icon 7",
    "Icon 8",
    "Icon 9",
    "Icon 10",
  ];
  bool decrypt = false;
  String decrypted = "";
  late Color color;
  late int index;
  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 9), radix: 16) + 0xFF000000);
  }

  bool didAuthenticate = false;
  Future<bool> authenticateIsAvailable() async {
    var localAuth = LocalAuthentication();
    final isAvailable = await localAuth.canCheckBiometrics;
    final isDeviceSupported = await localAuth.isDeviceSupported();
    log("Called Can Auth And Result Was: ${(isAvailable && isDeviceSupported).toString()}");
    return isAvailable && isDeviceSupported;
  }

  authenticate() async {
    if (!await authenticateIsAvailable()) return;
    var localAuth = LocalAuthentication();
    didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to view password',
        options: const AuthenticationOptions(stickyAuth: true));
  }

  Future<String> getMasterPass() async {
    const storage = FlutterSecureStorage();
    String masterPass = await storage.read(key: 'master') ?? '';
    return masterPass;
  }

  @override
  void initState() {
    log(widget.password.color);
    color = hexToColor(widget.password.color);
    index = iconNames.indexOf(widget.password.icon);
    authenticate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      key: scaffoldKey,
      // backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              height: size.height * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    icons[index],
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      widget.password.appName,
                      style: const TextStyle(
                          fontFamily: "Title",
                          fontSize: 32,
                          color: Colors.white),
                    ),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Username",
                    style: TextStyle(fontFamily: 'Title', fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                  child: Text(
                    widget.password.userName,
                    style: const TextStyle(
                      fontFamily: 'Subtitle',
                      fontSize: 20,
                      // color: Colors.black54
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Password",
                            style: TextStyle(fontFamily: 'Title', fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 8),
                          child: Text(
                            decrypt ? decrypted : widget.password.password,
                            style: const TextStyle(
                              fontFamily: 'Subtitle',
                              fontSize: 20,
                              // color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () async {
                        if (!decrypt && !didAuthenticate) {
                          buildShowDialogBox(context);
                        } else if (!decrypt && didAuthenticate) {
                          String masterPass = await getMasterPass();
                          decryptPass(widget.password.password, masterPass);
                        } else if (decrypt) {
                          setState(() {
                            decrypt = !decrypt;
                          });
                        }
                      },
                      icon: decrypt
                          ? const Icon(Icons.lock_open)
                          : const Icon(Icons.lock),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future buildShowDialogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Master Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "To decrypt the password enter your master password:",
                style: TextStyle(fontFamily: 'Subtitle'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  maxLength: 32,
                  decoration: InputDecoration(
                      hintText: "Master Pass",
                      hintStyle: const TextStyle(fontFamily: "Subtitle"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                  controller: masterPassController,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                decryptPass(
                    widget.password.password, masterPassController.text.trim());
                masterPassController.clear();
                if (!decrypt) {
                  const snackBar = SnackBar(
                    content: Text(
                      'Wrong Master Password',
                      style: TextStyle(fontFamily: "Subtitle"),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Text("DONE"),
            )
          ],
        );
      },
    );
  }

  decryptPass(String encryptedPass, String masterPass) {
    String keyString = masterPass;
    if (keyString.length < 32) {
      int count = 32 - keyString.length;
      for (var i = 0; i < count; i++) {
        keyString += ".";
      }
    }

    final iv = encrypt.IV.fromLength(16);
    final key = encrypt.Key.fromUtf8(keyString);

    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final d = encrypter.decrypt64(encryptedPass, iv: iv);
      setState(() {
        decrypted = d;
        decrypt = true;
      });
    } catch (exception) {
      setState(() {
        decrypted = "Wrong Master Password";
      });
    }
  }
}
