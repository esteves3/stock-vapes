import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

SharedPreferences? sharedPreferences;
DocumentReference<Map<String, dynamic>> repositoryBase =
    FirebaseFirestore.instance.collection("prod").doc("data");
bool isWeb = kIsWeb;
