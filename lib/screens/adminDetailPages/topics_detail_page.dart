import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/screens/admin_page.dart';

class TopicsDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> activeTopicData;

  const TopicsDetailPage({
    Key? key,
    required this.userData,
    required this.activeTopicData,
  }) : super(key: key);

  @override
  State<TopicsDetailPage> createState() => _TopicsDetailPageState();
}

class _TopicsDetailPageState extends State<TopicsDetailPage> {
  late Map<String, dynamic> _TopicuserData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.activeTopicData['user_id'])
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          _TopicuserData = snapshot.data() as Map<String, dynamic>;
        });
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }

  Future<void> deleteTopic(BuildContext context) async {
    try {
      // Store topic data in the topics_archive table
      await FirebaseFirestore.instance
          .collection('topics_archive')
          .doc(widget.activeTopicData['topics_id'])
          .set({
        'admin_id': widget.activeTopicData['admin_id'],
        'contents': widget.activeTopicData['contents'],
        'date': widget.activeTopicData['date'],
        'like_number': widget.activeTopicData['like_number'],
        'topics_id': widget.activeTopicData['topics_id'],
        'user_id': widget.activeTopicData['user_id'],
      });

      // Delete the topic from the topics table
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.activeTopicData['topics_id'])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Konu başarıyla silindi."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Konu silinirken bir hata oluştu."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateTopicData(
      Map<String, dynamic> updatedTopicData, BuildContext context) async {
    try {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .doc(widget.activeTopicData['topics_id'])
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
      await userSnapshot.reference.update(updatedTopicData);

      // Güncelleme başarılı olduğunda kullanıcıya geri bildirim verin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kullanıcı bilgileri güncellendi."),
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
      // Hata durumunda kullanıcıya geri bildirim verin veya hata işleyin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir hata oluştu, lütfen tekrar deneyin."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editTopics(BuildContext context) async {
    final TextEditingController theController =
        TextEditingController(text: widget.activeTopicData['admin_onay']);
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
            height: MediaQuery.of(context).copyWith().size.height * (1 / 4),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: theController.text,
                        items: [
                          "0",
                          "1",
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          theController.text = value!;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Onay Durumu',
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final updatedTopicData = {
                              'admin_onay': theController.text,
                            };
                            await updateTopicData(
                                updatedTopicData, context); // Pass context here
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
    final formattedDate = DateFormat('dd.MM.yyyy').format(
      (widget.activeTopicData['date'] as Timestamp).toDate(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Topik Bilgileri"),
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
                      Icons.calendar_today_sharp,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      '$formattedDate',
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
                        deleteTopic(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        editTopics(context);
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'İÇERİK  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Color.fromARGB(255, 47, 47, 47),
                  ),
                  color: Color.fromARGB(255, 199, 217, 244),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        ' ${widget.activeTopicData['contents']}',
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            color: Color.fromARGB(255, 65, 20, 4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'ONAY DURUMU  :  ',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  '${widget.activeTopicData['admin_onay']} ',
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
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '-KULLANICI BİLGİLERİ-',
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
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KULLANICI AD  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  '${_TopicuserData['name']} ',
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
                  'KULLANICI SOYAD  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  '${_TopicuserData['surname']}',
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
                  'KULLANICI E-MAİL  :',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${_TopicuserData['email']}',
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
                  ' ${_TopicuserData['user_type']}',
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
                  ' ${_TopicuserData['user_id']}',
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
