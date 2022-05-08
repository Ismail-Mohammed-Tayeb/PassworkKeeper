import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'PasswordHomepage.dart';

class SetMasterPassword extends StatefulWidget {
  const SetMasterPassword({Key? key}) : super(key: key);

  @override
  _SetMasterPasswordState createState() => _SetMasterPasswordState();
}

class _SetMasterPasswordState extends State<SetMasterPassword> {
  TextEditingController masterPassController = TextEditingController();

  Future<void> getMasterPass() async {
    const storage = FlutterSecureStorage();
    String masterPass = await storage.read(key: 'master') ?? '';
    masterPassController.text = masterPass;
  }

  saveMasterPass(String masterPass) async {
    const storage = FlutterSecureStorage();

    await storage.write(key: 'master', value: masterPass);
  }

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
    bool didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Please authenticate to change master password',
      options: const AuthenticationOptions(stickyAuth: true),
    );

    if (!didAuthenticate) {
      Navigator.pop(context);
    }

    log(didAuthenticate.toString());
  }

  @override
  void initState() {
    super.initState();
    authenticate();
    getMasterPass();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                margin: EdgeInsets.only(top: size.height * 0.05),
                child: Text("Master Password",
                    style: TextStyle(
                        fontFamily: "Title",
                        fontSize: 32,
                        color: primaryColor))),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Set Master Passwords for your all passwords. Keep your Master Password safe with you. This password will be used to unlock your encrypted passwords.",
              style: TextStyle(
                  fontSize: 16,
                  // color: Colors.black54,
                  fontStyle: FontStyle.italic,
                  fontFamily: "Subtitle"),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                obscureText: true,
                maxLength: 32,
                decoration: InputDecoration(
                    labelText: "Master Pass",
                    labelStyle: const TextStyle(fontFamily: "Subtitle"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16))),
                controller: masterPassController,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: size.width * 0.7,
                height: 60,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  color: primaryColor,
                  child: const Text(
                    "CONFIRM",
                    style: TextStyle(color: Colors.white, fontFamily: "Title"),
                  ),
                  onPressed: () async {
                    if (masterPassController.text.isNotEmpty) {
                      saveMasterPass(masterPassController.text.trim());
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const PasswordHomepage(),
                        ),
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                "Error!",
                                style: TextStyle(fontFamily: "Title"),
                              ),
                              content: const Text(
                                "Please enter valid Master Password.",
                                style: TextStyle(fontFamily: "Subtitle"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("CLOSE"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
