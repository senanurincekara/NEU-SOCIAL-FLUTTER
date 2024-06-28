// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:neu_social/screens/home_page.dart';
// import 'package:neu_social/screens/signin_screen.dart';

// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           //user is logged in
//           if (snapshot.hasData) {
//             // return HomePage(
//             //   userData: {},
//             // );

//             return HomePage();
//           }

//           //user is not in logged
//           else {
//             return SignInScreen();
//           }
//         },
//       ),
//     );
//   }
// }
