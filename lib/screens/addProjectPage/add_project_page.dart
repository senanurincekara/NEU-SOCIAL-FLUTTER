import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:neu_social/screens/project_page.dart';

class AddProjectPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AddProjectPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  TextEditingController _searchController = TextEditingController();
  final List<String> classOptions = ["Hazırlık", "1", "2", "3", "4"];
  List<String> dersOptions = [];
  String pdfFileName = '';
  String imageFileName = '';
  String selectedClass = ''; // Sınıf değerini tutacak değişken
  String selectedDers = '';
  TextEditingController _projeAdiController = TextEditingController();
  TextEditingController _projeIcerikController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDersOptions();
  }

  void fetchDersOptions() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('ders').get();

      List<String> dersAdList = [];
      querySnapshot.docs.forEach((doc) {
        dersAdList.add(doc['ders_ad']);
      });

      setState(() {
        dersOptions = dersAdList;
      });
    } catch (e) {
      print('Error fetching ders options: $e');
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcının dışarı tıklamasını engeller
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Yükleniyor animasyonu
              SizedBox(height: 16),
              Text(
                "Proje yükleniyor...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                "Proje başarıyla eklendi",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                "Proje eklenirken bir hata oluştu",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void addProject() async {
    // Diğer verileri al
    String dersAd = selectedDers;
    String sinif = selectedClass;
    String projeAdi = _projeAdiController.text;
    String projeIcerik = _projeIcerikController.text;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Tüm alanların doluluğunu kontrol et
    if (dersAd.isEmpty ||
        sinif.isEmpty ||
        projeAdi.isEmpty ||
        projeIcerik.isEmpty ||
        pdfFileName.isEmpty) {
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm alanları doldurun !'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      try {
        showLoadingDialog(context);
        // Firestore'a proje verilerini ekle
        String projectId =
            FirebaseFirestore.instance.collection('projeler').doc().id;
        DateTime currentDate = DateTime.now();
        Map<String, dynamic> projectData = {
          'proje_ad': projeAdi,
          'proje_class': sinif,
          'proje_ders_ad': dersAd,
          'date': currentDate,
          'proje_text': projeIcerik,
          'proje_id': projectId,
          'user_id': widget.userData['user_id'],
          'onay_durumu': '0', // Onay durumu
          'pdf_url': '',
          'like_number': []
        };

        await FirebaseFirestore.instance
            .collection('projeler')
            .doc(projectId)
            .set(projectData);

        // Firebase Storage'a PDF dosyasını yükle
        await uploadPDF(projectId);

        Navigator.pop(context); // Loading dialog kapat
        showSuccessDialog(context);
      } catch (e) {
        print("Hata: $e");
        Navigator.pop(context); // Loading dialog kapat
        showErrorDialog(context);
        scaffoldMessenger?.showSnackBar(
          SnackBar(
            content: Text('Proje eklenirken bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> uploadPDF(String projectId) async {
    try {
      String userId = widget.userData['user_id'];
      // PDF dosyasını Firebase Storage'a yükle
      if (pdfFileName != null) {
        final pdfFile = File(pdfFileName);
        // Dosyanın varlığını kontrol et
        if (!pdfFile.existsSync()) {
          print('Seçilen PDF dosyası mevcut değil.');
          return;
        }
        String fileName =
            'pdf/${userId}/${projectId}/${pdfFileName.split('/').last}';
        UploadTask uploadTask =
            FirebaseStorage.instance.ref(fileName).putFile(pdfFile);
        TaskSnapshot snapshot = await uploadTask;

        // Yükleme tamamlandıktan sonra URL'yi Firestore'a kaydet
        String downloadURL = await snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('projeler')
            .doc(projectId)
            .update({'pdf_url': downloadURL});
      } else {
        print('PDF dosyası bulunamadı.');
      }
    } catch (e) {
      print('PDF yüklenirken hata oluştu: $e');
      throw e;
    }
  }

  void selectFile() async {
    // PDF dosyasını seçmek için dosya seçiciyi çağır
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // Seçilen dosyanın yolunu alıyorum burda
      String filePath = result.files.single.path!;

      setState(() {
        pdfFileName = filePath;
      });
    } else {
      // Kullanıcı dosya seçmedi veya bir hata oluştu
      // Gerekirse burada bir hata mesajı gösterebilirsiniz
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      appBar: AppBar(
        title: Text(
          "PROJE EKLE",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 1, 8, 52),
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 216, 248, 255),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 1, 8, 52),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectPage(userData: widget.userData),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          _mainIcon(),
          _Inputs(),
        ],
      ),
    );
  }

  Widget _mainIcon() {
    return CircleAvatar(
      radius: 170, // Dairenin yarıçapı
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      child: CircleAvatar(
        radius: 200, // İçteki dairenin yarıçapı, biraz daha küçük olmalı
        // İçteki dairenin arka plan rengi
        backgroundColor: Color.fromARGB(255, 216, 248, 255),
        child: ClipOval(
          child: Image.asset(
            'assets/images/drawer.png', // Resmin dosya yolunu belirt
            width: 450, // Resmin genişliği
            height: 450, // Resmin yüksekliği
            // Resmi dairesel alana sığdırmak için
          ),
        ),
      ),
    );
  }

  Widget _Inputs() {
    return Flexible(
      child: SingleChildScrollView(
        child: Container(
          // color: Color.fromARGB(255, 7, 185, 255),
          margin: EdgeInsets.only(top: 18, bottom: 16.0),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ders Ad:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: dersOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedDers = value ?? '';
                    });
                  },
                ),
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
                items: classOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedClass = value ?? ''; // Seçilen sınıfı güncelle;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                'Proje Ad:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _projeAdiController, // Controller atanması
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                // initialValue: ,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 10),
              Text(
                'Proje İçerik:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _projeIcerikController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                // initialValue: ,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 10),
              SizedBox(height: 20),
              GestureDetector(
                onTap: selectFile,
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      dashPattern: [10, 4],
                      strokeCap: StrokeCap.round,
                      color: const Color.fromARGB(255, 22, 105, 173),
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50.withOpacity(.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drive_folder_upload_outlined,
                              color: const Color.fromARGB(255, 22, 105, 173),
                              size: 40,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              pdfFileName.isNotEmpty
                                  ? pdfFileName.split('/').last
                                  : 'PDF Dosyanı Yükle', // Dosya adını kontrol et ve yazdır

                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 13, 150, 249)),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 112, 169, 181),
                        side: BorderSide(
                            width: 1, color: Color.fromARGB(255, 73, 169, 210)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                          20,
                        ))),
                    onPressed: () {
                      addProject();
                      setState(() {
                        // FutureBuilder'ın yeniden çalışması için state'i güncelliyoruz
                      });
                    },
                    child: Wrap(children: <Widget>[
                      Icon(
                        Icons.check_circle_outline_outlined,
                        color: Color.fromARGB(255, 255, 243, 224),
                        size: 22.0,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        'Yükle',
                        style: TextStyle(fontSize: 16),
                      )
                    ]),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
