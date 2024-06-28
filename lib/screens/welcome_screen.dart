import 'package:flutter/material.dart';
import 'package:neu_social/screens/signin_screen.dart';
import 'package:neu_social/screens/signup_screen.dart';
import 'package:neu_social/themes/theme.dart';
import 'package:neu_social/widgets/custom_scaffold.dart';
import 'package:neu_social/widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
            ),
          ),
          Flexible(
            flex: 10, // giriş yap ve kayıt ol yükseklği belirleniyor
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Giriş yap',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Color.fromARGB(255, 2, 27, 81),
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Kayıt ol',
                      onTap: const SignUpScreen(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
