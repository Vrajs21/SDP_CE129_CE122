import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:noshup_admin/model/auth.dart';
import 'package:noshup_admin/screens/Order/orderpage.dart';
import 'package:noshup_admin/screens/Profile/Profile.dart';
import 'package:noshup_admin/screens/Profile/editProfile.dart';
import 'package:noshup_admin/screens/Registration/login.dart';
import 'package:noshup_admin/screens/Registration/resetpassowrd.dart';
import 'package:noshup_admin/screens/Registration/signup.dart';

import 'package:noshup_admin/screens/menupages/menu.dart';
import 'package:noshup_admin/screens/menupages/menuItem.dart';
import 'package:noshup_admin/screens/splash.dart';
import 'package:noshup_admin/utils/routes.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAn5zlDAm0O_nJ5a-Yjr9hqU-nRQPILaAQ",
          authDomain: "canteen-2a462.firebaseapp.com",
          projectId: "canteen-2a462",
          storageBucket: "canteen-2a462.appspot.com",
          messagingSenderId: "558188152074",
          appId: "1:558188152074:web:f37448a00fefc02d2526f3",
          measurementId: "G-0RTGJJD3PG"));
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthNotifier(),
      ),
      // ChangeNotifierProvider(
      //   create: (_) => FoodNotifier(),
      // ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoshUp_Admin',
      theme: ThemeData(
        fontFamily: 'Questrial',
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red)
            .copyWith(secondary: Colors.redAccent),
      ),
      initialRoute: MyRoutes.splashPage,
      routes: {
        MyRoutes.SignUpRoute: (context) => SignUp(),
        MyRoutes.ResetPasswordRoute: (context) => ResetPassword(),
        MyRoutes.loginPage: (context) => AdminLoginPage(),
        MyRoutes.splashPage: (context) => Splash(),
        MyRoutes.menuPageRoute: (context) => MenuPage(),
        MyRoutes.ProfilePageRoute: (context) => ProfilePage(),
        // MyRoutes.EditProfilePageRoute: (context) => EditProfile(),
        MyRoutes.menuItemPageRoute: (context) => MenuItem(),
        MyRoutes.OrderPageRoute: (context) => OrderPage(),
      },
    );
  }
}
