import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neu_social/screens/avatar_select.dart';
import 'package:neu_social/widgets/bottomNavigationBar.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? surname;
  String? classValue;
  String? phoneNumber;
  String? bio;
  ImageProvider<Object>? avatarImage;

  final List<String> classOptions = ["Hazırlık", "1", "2", "3", "4"];

  TextEditingController? _phoneNumberController;

  @override
  void initState() {
    super.initState();
    fetchData();
    _phoneNumberController =
        TextEditingController(); // TextEditingController başlatılıyor
  }

  void fetchData() {
    // Assign user ID from userData to my_user_id
    String my_user_id = widget.userData['user_id'];

    // Fetch user data from Firestore using the user ID
    FirebaseFirestore.instance
        .collection('users')
        .doc(my_user_id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Extract user data from the document
        setState(() {
          name = documentSnapshot['name'] ?? '';
          surname = documentSnapshot['surname'] ?? '';
          classValue = documentSnapshot['class'] ?? '';
          phoneNumber = documentSnapshot['phoneNumber'] ?? '';
          bio = documentSnapshot['bio'] ?? '';
          // Get the avatar image URL from Firestore
          String avatarURL = documentSnapshot['avatar_image'] ?? '';
          // Update the avatar image in the UI
          if (avatarURL.isNotEmpty) {
            // Use NetworkImage instead of AssetImage
            avatarImage = NetworkImage(avatarURL);
          }
        });
      } else {
        print('User data not found');
      }
    }).catchError((error) {
      print('Error getting user data: $error');
    });
  }

  @override
  void dispose() {
    _phoneNumberController?.dispose(); // TextEditingController temizleniyor
    super.dispose();
  }

  void updateUserProfile(Map<String, dynamic> updatedData) {
    // Kullanıcının user_id'sine göre Firestore kullanıcılar koleksiyonundaki belgeyi güncelleme

    FirebaseFirestore.instance
        .collection('users')
        .doc(updatedData['user_id'])
        .update(updatedData)
        .then((value) {
      print("Kullanıcı profil bilgileri başarıyla güncellendi");
    }).catchError((error) {
      print("Hata oluştu: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/backProfile.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PROFİL",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 3, 3, 3),
                    fontSize: 20.0,
                  ),
                ),
                Icon(
                  Icons.insert_emoticon_outlined,
                  size: 28,
                )
              ],
            ),
            backgroundColor: Colors.transparent,
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            // HomePage(userData: userData), // userData parametresini sağla
                            MyBottomNavBar(userData: widget.userData)),
                  );
                }),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 64, 3, 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 1, 9, 41)
                                          .withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: avatarImage,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    _showEditProfilePanel(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 36, 35, 35),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                                  255, 20, 19, 19)
                                              .withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.settings,
                                      size: 20,
                                      color: const Color.fromARGB(
                                          255, 241, 235, 235),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 246, 186),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black38),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 0, 68, 132)
                                        .withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ad Soyad : ",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      Text(
                                        "$name $surname",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Text(
                                        "Sınıf : ",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      Text(
                                        "$classValue",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0), // Add some space
                                  Row(
                                    children: [
                                      Text(
                                        "Email : ",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      Text(
                                        "${widget.userData['email']}",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Text(
                                        "Telefon : ",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      Text(
                                        "$phoneNumber",
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 107, 129, 182),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.black54),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 1, 108, 92),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Hakkımda  ",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0,
                                          color:
                                              Color.fromARGB(255, 42, 11, 81)),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showEditBioPanel(context);
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color:
                                            Color.fromARGB(255, 192, 219, 255),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "$bio ",
                                  style: TextStyle(
                                    fontFamily: 'Times New Roman',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromARGB(255, 192, 219, 255),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditBioPanel(BuildContext context) {
    String bio = widget.userData['bio'] ?? ''; // Initialize bio variable

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height * (3.5 / 5),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hakkımda:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      initialValue: bio,
                      onChanged: (value) {
                        setState(() {
                          bio = value;
                        });
                      },
                      maxLines: null, // Allow multiline input
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (bio.isNotEmpty) {
                          try {
                            // Update Firestore document with the new bio
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userData['user_id'])
                                .update({'bio': bio});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hakkımda bilgisi güncellendi.'),
                                backgroundColor:
                                    Color.fromARGB(255, 32, 160, 39),
                              ),
                            );
                          } catch (error) {
                            print("Error updating bio: $error");

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Hakkımda bilgisi güncellenirken bir hata oluştu.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Lütfen hakkınızda bir şeyler yazın.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Güncelle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditProfilePanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ad:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  initialValue: name,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Soyad:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  initialValue: surname,
                  onChanged: (value) {
                    setState(() {
                      surname = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Sınıf:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: classValue,
                  items: classOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      classValue = value!;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Telefon:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Lütfen telefon numaranızı giriniz',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  initialValue: phoneNumber,
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen telefon numaranızı giriniz';
                    } else if (value.length != 11) {
                      return 'Telefon numarası 11 haneli olmalıdır';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 2),
                Text(
                  (_phoneNumberController?.text.length != 11 &&
                          _phoneNumberController!.text.isNotEmpty)
                      ? 'Lütfen 11 haneli telefon numarası giriniz'
                      : '',
                  style: TextStyle(color: Colors.red),
                ),
                // SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // background (button) color
                        foregroundColor:
                            Colors.white, // foreground (text) color
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (phoneNumber?.length == 11 &&
                            phoneNumber!.isNotEmpty) {
                          updateUserProfile({
                            'user_id': widget.userData[
                                'user_id'], // Kullanıcı ID'sini ekliyoruz
                            'name': name,
                            'surname': surname,
                            'class': classValue,
                            'phoneNumber': phoneNumber,
                            // Diğer alanları gerektiği gibi ekleyin
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Güncelleme işlemi gerçekleştirildi.'),
                              backgroundColor: Color.fromARGB(255, 32, 160, 39),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Lütfen tüm alanları doğru bir şekilde doldurun.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Güncelle'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AvatarSelect(userData: widget.userData)),
                        );
                      },
                      child: Text("Avatar Seç"),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
