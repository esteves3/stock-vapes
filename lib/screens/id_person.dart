import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stock_vapes/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_vapes/utils/configs.dart';

class IdPerson extends StatefulWidget {
  const IdPerson({super.key});

  @override
  State<IdPerson> createState() => _IdPersonState();
}

class _IdPersonState extends State<IdPerson> {
  String password = "";
  var hidePassword = true, btnLoading = false;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.amber),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height / 8)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 8,
              ),
              child: const AutoSizeText(
                "Inserir código de autenticação",
                maxLines: 1,
                maxFontSize: 40,
                style: TextStyle(
                  fontSize: 100,
                ),
              ).animate().fadeIn(duration: 1500.ms).moveY(duration: 400.ms),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                onChanged: (value) => setState(() {
                  password = value;
                }),
                onSubmitted: (value) {
                  login();
                },
                style: const TextStyle(
                  fontSize: 20,
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
                obscureText: true,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            if (password.isNotEmpty)
              ElevatedButton(
                onPressed: login,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnLoading
                      ? const CircularProgressIndicator.adaptive()
                      : const Icon(CupertinoIcons.arrow_right),
                ),
              )
                  .animate()
                  .fadeIn(duration: 900.ms)
                  .moveY(duration: 300.ms, begin: 5),
            Expanded(
              flex: 8,
              child: Container(),
            ),
          ],
        ));
  }

  void login() async {
    if (password.isEmpty) return;
    setState(() {
      btnLoading = true;
    });

    var user = await repositoryBase
        .collection("users")
        .where("code", isEqualTo: password)
        .get();

    if (user.docs.isEmpty) {
      setState(() {
        btnLoading = false;
      });
      return;
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Home(
                name: user.docs[0].data()["name"],
                type: user.docs[0].data()["type"],
                id: user.docs[0].data()["id"])));
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("name", user.docs[0].data()["name"]);
    prefs.setString("type", user.docs[0].data()["type"]);
    prefs.setInt("id", user.docs[0].data()["id"]);
  }
}
