import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:neu_social/screens/admin_page.dart';

class UsersDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> activeUserData;

  const UsersDetailPage({
    Key? key,
    required this.userData,
    required this.activeUserData,
  }) : super(key: key);

  @override
  State<UsersDetailPage> createState() => _UsersDetailPageState();
}

class _UsersDetailPageState extends State<UsersDetailPage> {
  Future<void> updateUserData(Map<String, dynamic> updatedUserData) async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.activeUserData['user_id'])
          .get();

      if (!userSnapshot.exists) {
        // Belge bulunamadıysa hata göster ve işlemi durdur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kullanıcı bulunamadı."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Belge varsa güncelleme işlemini gerçekleştir
      await userSnapshot.reference.update(updatedUserData);

      // Güncelleme başarılı olduğunda kullanıcıya geri bildirim verin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı bilgileri güncellendi."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Hata durumunda kullanıcıya geri bildirim verin veya hata işleyin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir hata oluştu, lütfen tekrar deneyin."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      // Store user data in the user_archive table
      await FirebaseFirestore.instance
          .collection('user_archive')
          .doc(widget.activeUserData['user_id'])
          .set({
        'class': widget.activeUserData['class'],
        'email': widget.activeUserData['email'],
        'name': widget.activeUserData['name'],
        'password': widget.activeUserData['password'],
        'phoneNumber': widget.activeUserData['phoneNumber'],
        'school_number': widget.activeUserData['school_number'],
        'surname': widget.activeUserData['surname'],
        'user_id': widget.activeUserData['user_id'],
        'user_type': widget.activeUserData['user_type'],
      });

      // Delete the user from the users table
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.activeUserData['user_id'])
          .delete();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı başarıyla silindi."),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the HomePage after the deletion process is complete
      Navigator.pop(context); // Close the current page
    } catch (e) {
      // Show an error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı silinirken bir hata oluştu."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editUser(BuildContext context) async {
    final TextEditingController nameController =
        TextEditingController(text: widget.activeUserData['name']);
    final TextEditingController surnameController =
        TextEditingController(text: widget.activeUserData['surname']);
    final TextEditingController schoolNumberController =
        TextEditingController(text: widget.activeUserData['school_number']);
    final TextEditingController classController =
        TextEditingController(text: widget.activeUserData['class']);
    final TextEditingController phoneNumberController =
        TextEditingController(text: widget.activeUserData['phoneNumber']);
    final TextEditingController emailController =
        TextEditingController(text: widget.activeUserData['email']);
    final TextEditingController passwordController =
        TextEditingController(text: widget.activeUserData['password']);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height * (3.5 / 5),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adı',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ad boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: surnameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Soyadı',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Soyad boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: schoolNumberController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Okul Numarası',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Okul numarası boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: classController.text,
                        items: ["Hazırlık", "1", "2", "3", "4"]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          classController.text = value!;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Sınıf',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sınıf bilgisi boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Telefon Numarası',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Telefon numarası boş bırakılamaz';
                          }
                          if (value.length != 11) {
                            return 'Telefon numarası 11 haneli olmalıdır';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Şifre',
                          labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 20, 36)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final updatedUserData = {
                              'name': nameController.text,
                              'surname': surnameController.text,
                              'school_number': schoolNumberController.text,
                              'class': classController.text,
                              'phoneNumber': phoneNumberController.text,
                              'email': emailController.text,
                              'password': passwordController.text,
                            };
                            await updateUserData(updatedUserData);
                            // Güncelleme işlemi tamamlandıktan sonra kullanıcı verilerini güncellenmiş verilere göre yeniden al
                            final Map<String, dynamic> updatedUser = {
                              ...widget.activeUserData,
                              ...updatedUserData,
                            };

                            // Güncelleme işlemi tamamlandıktan sonra sayfayı yenile
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    UsersDetailPage(
                                  userData: widget.userData,
                                  activeUserData: updatedUser,
                                ),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build your detail page UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Bilgileri'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        // HomePage(userData: userData), // userData parametresini sağla
                        AdminPage(userData: widget.userData)),
              );
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_box_outlined,
                      color: Color.fromARGB(255, 22, 88, 146),
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      '${widget.activeUserData['name']} ${widget.activeUserData['surname']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color.fromARGB(255, 2, 23, 55),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteUser(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        editUser(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KULLANICI ID  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['user_id']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KULLANICI TİPİ  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['user_type']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OKUL NUMARASI  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['school_number']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SINIF BİLGİSİ :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['class']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TELEFON NUMARASI  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['phoneNumber']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'E - MAİL  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['email']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ŞİFRE  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeUserData['password']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
