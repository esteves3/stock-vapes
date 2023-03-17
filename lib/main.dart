import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_vapes/screens/backoffice.dart';
import 'package:stock_vapes/screens/home.dart';
import 'package:stock_vapes/screens/id_person.dart';
import 'package:stock_vapes/screens/orders.dart';
import 'package:stock_vapes/utils/configs.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  sharedPreferences = await SharedPreferences.getInstance();
  /*for (var path in ["orders", "products", "sales", "stock", "users"]) {
    for (var e
        in (await FirebaseFirestore.instance.collection(path).get()).docs) {
      await repositoryBase.collection(path).add(e.data());
    }
  }*/

  /*for (var element in (await FirebaseFirestore.instance
          .collection("qa")
          .doc("data")
          .collection("products")
          .get())
      .docs) {
    print(element);
    if ((await FirebaseFirestore.instance
            .collection("prod")
            .doc("data")
            .collection("products")
            .where("id", isEqualTo: element.data()["id"])
            .get())
        .docs
        .isEmpty) {
      await FirebaseFirestore.instance
          .collection("prod")
          .doc("data")
          .collection("products")
          .add(element.data());
    }
  }*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vapes Stock',
      color: Colors.transparent,
      theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.orange)),
          appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              color: Colors.transparent,
              systemOverlayStyle:
                  SystemUiOverlayStyle(statusBarColor: Colors.orange)),
          cardTheme: const CardTheme(color: Color(0xFFF5F5F5)),
          iconTheme: const IconThemeData(color: Colors.black),
          inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black)),
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              fontFamily: GoogleFonts.aBeeZee().fontFamily)),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFF212121),
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.orange)),
          appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              color: Colors.transparent,
              systemOverlayStyle:
                  SystemUiOverlayStyle(statusBarColor: Colors.orange)),
          cardTheme: const CardTheme(color: Color(0xFF413D3D)),
          iconTheme: const IconThemeData(color: Colors.white),
          inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white)),
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              fontFamily: GoogleFonts.aBeeZee().fontFamily)),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => sharedPreferences!.containsKey("name")
            ? Home(
                name: sharedPreferences!.getString("name").toString(),
                type: sharedPreferences!.getString("type").toString(),
                id: sharedPreferences!.getInt("id")!,
              )
            : const IdPerson(),
        '/orders': (context) => const Orders(),
        '/backoffice': (context) => const BackOffice()
      },
    );
  }
}
