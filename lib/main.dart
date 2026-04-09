// import 'package:flutter/material.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:movie_app/screens/forget_password/forget_password_screen.dart';
// import 'package:movie_app/screens/login/login_screen.dart';
// import 'package:movie_app/screens/main/main_screen.dart';
// import 'package:movie_app/screens/movie_detail_screen/movie_details_screen.dart';
// import 'package:movie_app/screens/onboarding/onboarding_view.dart';
// import 'package:movie_app/screens/register/language_provider.dart';
// import 'package:movie_app/screens/register/register_screen.dart';
// import 'package:movie_app/screens/splash/splash_screen.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => LanguageProvider(),
//       child: const MovieApp(),
//     ),
//   );
// }

// class MovieApp extends StatefulWidget {
//   const MovieApp({super.key});

//   @override
//   State<MovieApp> createState() => _MovieAppState();
// }

// class _MovieAppState extends State<MovieApp> {
//   @override
//   Widget build(BuildContext context) {
//     // بنجيب اللغة الحالية من الـ Provider
//     final langProvider = Provider.of<LanguageProvider>(context);
//     return MaterialApp(
//       locale: langProvider.currentLocale, // هنا بنربط لغة التطبيق بالبروفايدر
//       supportedLocales: const [Locale('en'), Locale('ar')],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       debugShowCheckedModeBanner: false,
//       initialRoute: 'splash',
//       routes: {
//         'splash': (context) => const SplashScreen(),
//         'onboarding': (context) => const OnboardingView(),
//         'register': (context) => const RegisterScreen(),
//         'login': (context) => const LoginScreen(),
//         'forget_password': (context) => const ForgetPasswordScreen(),
//         'main': (context) => const MainScreen(),
//       },

//       onGenerateRoute: (settings) {
//         if (settings.name == 'movieDetails') {
//           final movieId = settings.arguments as int;
//           return MaterialPageRoute(
//             builder: (_) => MovieDetailsScreen(movieId: movieId),
//           );
//         }
//         return null;
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:movie_app/screens/forget_password/forget_password_screen.dart';
import 'package:movie_app/screens/login/login_screen.dart';
import 'package:movie_app/screens/main/main_screen.dart';
import 'package:movie_app/screens/movie_detail_screen/movie_details_screen.dart';
import 'package:movie_app/screens/onboarding/onboarding_view.dart';
import 'package:movie_app/screens/register/language_provider.dart';
import 'package:movie_app/screens/register/register_screen.dart';
import 'package:movie_app/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const MovieApp(),
    ),
  );
}

class MovieApp extends StatefulWidget {
  const MovieApp({super.key});

  @override
  State<MovieApp> createState() => _MovieAppState();
}

class _MovieAppState extends State<MovieApp> {
  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Movie App',
      locale: langProvider.currentLocale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash',
      routes: {
        'splash': (context) => const SplashScreen(),
        'onboarding': (context) => const OnboardingView(),
        'register': (context) => const RegisterScreen(),
        'login': (context) => const LoginScreen(),
        'forget_password': (context) => const ForgetPasswordScreen(),
        'main': (context) => const MainScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'movieDetails') {
          final movieId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(movieId: movieId),
          );
        }
        return null;
      },
    );
  }
}
