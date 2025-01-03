import 'package:flutter/material.dart';
import 'package:profileapp/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:profileapp/pages/contestperformancepage.dart';
import 'package:profileapp/pages/favouriteproblem.dart';
import 'package:profileapp/pages/markedproblempage.dart';
import 'package:profileapp/pages/my_friends_page.dart';
import 'package:profileapp/pages/search_page.dart';
import 'package:profileapp/pages/splashscreen.dart';
import 'firebase_options.dart';
import 'pages/weeklyanalyticpage.dart';
import 'pages/monthlyanalyticpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthPage(),
        '/weekly': (context) => WeeklyAnalyticsPage(),
        '/monthly': (context) => MonthlyAnalyticsPage(),
        '/contest': (context) => const ContestPerformancePage(),
        '/favorite': (context) => FavouriteProblemsPage(),
        '/attempted': (context) => MarkedProblemsPage(),
        '/myFriends': (context) => MyFriendsAllPage(),
        '/searchFriends': (context) => SearchPage(),
      },
    );
  }
}
