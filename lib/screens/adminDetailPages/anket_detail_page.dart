import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/screens/admin_page.dart';

class AnketDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> activeSurveyData;
  const AnketDetailPage({
    Key? key,
    required this.userData,
    required this.activeSurveyData,
  }) : super(key: key);

  @override
  State<AnketDetailPage> createState() => _AnketDetailPageState();
}

class _AnketDetailPageState extends State<AnketDetailPage> {
  Future<void> deleteSurvey(BuildContext context) async {
    try {
      // Store topic data in the topics_archive table
      await FirebaseFirestore.instance
          .collection('anketArchive')
          .doc(widget.activeSurveyData['topics_id'])
          .set({
        'anket_id': widget.activeSurveyData['anket_id'],
        'contents': widget.activeSurveyData['text'],
        'anket_url': widget.activeSurveyData['anket_url'],
        'date': widget.activeSurveyData['date'],
      });

      // Delete the topic from the topics table
      await FirebaseFirestore.instance
          .collection('anketler')
          .doc(widget.activeSurveyData['anket_id'])
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anket başarıyla silindi."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Aanket silinirken bir hata oluştu."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateSurveyData(Map<String, dynamic> updatedSurveyData) async {
    try {
      final DocumentSnapshot surveySnapshot = await FirebaseFirestore.instance
          .collection('anketler')
          .doc(widget.activeSurveyData['anket_id'])
          .get();

      if (!surveySnapshot.exists) {
        // Belge bulunamadıysa hata göster ve işlemi durdur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Anket bulunamadı."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Belge varsa güncelleme işlemini gerçekleştir
      await surveySnapshot.reference.update(updatedSurveyData);

      // Güncelleme başarılı olduğunda kullanıcıya geri bildirim verin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anket bilgileri güncellendi."),
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

  Future<void> editSurvey(BuildContext context) async {
    final TextEditingController textController =
        TextEditingController(text: widget.activeSurveyData['text']);
    final TextEditingController urlController =
        TextEditingController(text: widget.activeSurveyData['anket_url']);

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
            height: MediaQuery.of(context).copyWith().size.height * (1.5 / 5),
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
                        controller: textController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Anket Açıklama',
                          labelStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 1, 20, 36),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Açıklama boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: urlController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Anket Adres',
                          labelStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 1, 20, 36),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Adres boş bırakılamaz';
                          }
                          if (!value.startsWith("https://forms.gle/")) {
                            return 'Adres "https://forms.gle/" ile başlamalıdır';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final updatedSurveyData = {
                              'text': textController.text,
                              'anket_url': urlController.text,
                              'anket_id': widget.activeSurveyData['anket_id'],
                              'date': widget.activeSurveyData['date']
                            };
                            await updateSurveyData(updatedSurveyData);
                            // Güncelleme işlemi tamamlandıktan sonra kullanıcı verilerini güncellenmiş verilere göre yeniden al
                            final Map<String, dynamic> updatedUser = {
                              ...widget.activeSurveyData,
                              ...updatedSurveyData,
                            };

                            // Güncelleme işlemi tamamlandıktan sonra sayfayı yenile
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    AnketDetailPage(
                                  userData: widget.userData,
                                  activeSurveyData: updatedUser,
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
    final formattedDate = DateFormat('dd.MM.yyyy').format(
      (widget.activeSurveyData['date'] as Timestamp).toDate(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Anket Bilgileri"),
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
                        deleteSurvey(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        editSurvey(context);
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
                        ' ${widget.activeSurveyData['text']}',
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Anket URL :  ',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 2, 23, 55),
                  ),
                ),
                Text(
                  ' ${widget.activeSurveyData['anket_url']}',
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
