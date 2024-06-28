import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neu_social/screens/signin_screen.dart';
import 'package:neu_social/themes/theme.dart';
import 'package:neu_social/widgets/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  String? selectedClass;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _schoolNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _addUserToFirestore() async {
    try {
      DocumentReference documentReference =
          await _firestore.collection('users').add({
        'class': selectedClass,
        'email': _emailController.text,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'password': _passwordController.text,
        'phoneNumber': _phoneNumberController.text,
        'school_number': _schoolNumberController.text,
        'avatar_image':
            'https://firebasestorage.googleapis.com/v0/b/project-3a626.appspot.com/o/avatars%2F7.png?alt=media&token=071e6f57-0b99-4210-a3b5-f9986c56d823',
        'bio': '',
        'user_type': 'user',
        'onay_durumu': '0',
      });

      String user_id = documentReference.id;
      await documentReference.update({'user_id': user_id});
      print('User added with ID: $user_id');
    } catch (e) {
      print('Firestore kayıt hatası: $e');
    }
  }

// List of class options
  List<String> classOptions = ["Hazırlık", "1", "2", "3", "4"];
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
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'ŞİMDİ ARAMIZA KATIL',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // name
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı giriniz';
                          }
                          return null;
                        },
                        controller: _nameController,
                        decoration: InputDecoration(
                          label: const Text('Ad'),
                          hintText: 'Lütfen adınızı giriniz',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
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

                      // soyad
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen soyadınızı giriniz';
                          }
                          return null;
                        },
                        controller: _surnameController,
                        decoration: InputDecoration(
                          label: const Text('Soyad'),
                          hintText: 'Lütfen soyadınızı giriniz',
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
                      // email
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Email adresinizi giriniz ';
                          }
                          return null;
                        },
                        controller: _emailController,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Email adresinizi giriniz',
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

                      // phone number
                      TextFormField(
                        controller: _phoneNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen telefon numaranızı giriniz';
                          } else if (value.length != 11) {
                            return 'Telefon numarası 11 haneli olmalıdır';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [LengthLimitingTextInputFormatter(11)],
                        decoration: InputDecoration(
                          label: const Text('Telefon No'),
                          hintText: 'Lütfen telefon numaranızı giriniz',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
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

                      // Öğrenci No
                      TextFormField(
                        controller: _schoolNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen öğrenci numaranızı giriniz';
                          } else if (value.length != 11) {
                            return 'Öğrenci numarası 11 haneli olmalıdır';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(11)],
                        decoration: InputDecoration(
                          label: const Text('Öğrenci No'),
                          hintText: 'Lütfen öğrenci numaranızı giriniz',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
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

                      DropdownButtonFormField<String>(
                        value: selectedClass,
                        onChanged: (String? value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen sınıf seçiniz';
                          }
                          return null;
                        },
                        items: classOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Sınıf',
                          hintText: 'Sınıfınızı seçin',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
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
                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi giriniz';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Şifre'),
                          hintText: 'Lütfen Şifrenizi giriniz',
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

                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Kayıt işleminiz onaylanmak üzere alındı , teşekkürler !'),
                                ),
                              );
                              _addUserToFirestore(); // Firestore'a kayıt ekleme işlemi
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen yeniden deneyiniz!'),
                                ),
                              );
                            }
                          },
                          child: const Text('Sign up'),
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Hesabın Var Mı? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Giriş Yap',
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
