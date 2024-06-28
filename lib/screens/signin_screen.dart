import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neu_social/screens/signup_screen.dart';
import 'package:neu_social/widgets/bottomNavigationBar.dart';
import 'package:neu_social/widgets/custom_scaffold.dart';
import '../themes/theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  bool rememberPassword = true;

  void signUserIn() async {
    if (_formSignInKey.currentState!.validate()) {
      final studentNumber = _studentNumberController.text;
      final password = _passwordController.text;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('school_number', isEqualTo: studentNumber)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data(); // Retrieve user data
        final isAdminApproved = userData['onay_durumu'] == '1';

        if (isAdminApproved) {
          // Kullanıcı girişi onaylandı, ana sayfaya yönlendir
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    // HomePage(userData: userData), // userData parametresini sağla
                    MyBottomNavBar(userData: userData)),
          );
        } else {
          // Kullanıcı girişi reddedildi, uyarı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yönetici tarafından onaylanmadınız.')),
          );
        }
      } else {
        // Kullanıcı bulunamadı, uyarı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öğrenci numarası veya şifre yanlış.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'NEÜ SOSYAL',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: _studentNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Öğrenci Numaranızı Giriniz';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Öğrenci No'),
                          hintText: 'Lütfen Öğrenci Numaranızı giriniz',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // kenarlı rengi
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Şifrenizi Giriniz';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Şifre'),
                          hintText: 'Lütfen şifrenizi giriniz',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Row(
                          //   children: [
                          //     Checkbox(
                          //       value: rememberPassword,
                          //       onChanged: (bool? value) {
                          //         setState(() {
                          //           rememberPassword = value!;
                          //         });
                          //       },
                          //       activeColor: lightColorScheme.primary,
                          //     ),
                          //     const Text(
                          //       'Remember me',
                          //       style: TextStyle(
                          //         color: Colors.black45,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          GestureDetector(
                            child: Text(
                              'Şifremi unuttum?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signUserIn,
                          child: Text('Giriş Yap'),
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Hesabın Yok Mu? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
