import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ktmobileapp/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'สมาคมพืชกระท่อมแห่งประเทศไทย',
      theme: ThemeData(
        textTheme: GoogleFonts.kodchasanTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.lightGreen,
      ),
      home: const LoginPage(),
    );
  }
}
