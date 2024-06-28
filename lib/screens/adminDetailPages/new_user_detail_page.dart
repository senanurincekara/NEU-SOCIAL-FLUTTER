import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:neu_social/screens/admin_page.dart';

class newUsersDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> activeUserData;

  const newUsersDetailPage({
    Key? key,
    required this.userData,
    required this.activeUserData,
  }) : super(key: key);

  @override
  State<newUsersDetailPage> createState() => _UsersDetailPageState();
}

class _UsersDetailPageState extends State<newUsersDetailPage> {
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

  void _onApproveButtonPressed() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.activeUserData['user_id'])
          .update({'onay_durumu': '1'});

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı onaylandı."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminPage(
                  userData: widget.userData,
                )),
      );
    } catch (e) {
      // Show an error message if updating fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı onaylanırken bir hata oluştu."),
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
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _onApproveButtonPressed,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Onayla',
                    style: TextStyle(fontSize: 16),
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
