import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavach_4k/child/bottom_page.dart';
import 'package:kavach_4k/db/share_pref.dart';
import 'package:kavach_4k/parent/parent_home_screen.dart';
import 'package:kavach_4k/utils/constants.dart';
import 'package:kavach_4k/child/bottom_screens/child_home_screen.dart';

import 'child/child_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MySharedPreffrences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kavach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
      ),
      // home: HomeScreen());
      home: FutureBuilder(
        future: MySharedPreffrences.getUserType(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return progressIndicator(context);
          } else {
            final userType = snapshot.data;
            if (userType == null || userType.isEmpty) {
              return LoginScreen();
            } else if (userType == "child") {
              return BottomPage();
            } else if (userType == "parent") {
              return ParentHomeScreen();
            } else {
              // Clear user type from shared preferences
              MySharedPreffrences.clearUserType();
              return LoginScreen();
            }
          }
        },
      ),
    );
  }
}