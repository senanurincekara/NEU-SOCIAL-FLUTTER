import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/screens/admin_page.dart';

class GamesDetailPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> nonactiveGameData;
  const GamesDetailPage({
    Key? key,
    required this.userData,
    required this.nonactiveGameData,
  }) : super(key: key);

  @override
  @override
  State<GamesDetailPage> createState() => _GamesDetailPageState();
}

class _GamesDetailPageState extends State<GamesDetailPage> {
  late Map<String, dynamic> _GameuserData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.nonactiveGameData['userId'])
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          _GameuserData = snapshot.data() as Map<String, dynamic>;
        });
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }

  Future<void> updateGameData(
      Map<String, dynamic> updatedGameData, BuildContext context) async {
    try {
      // Ana koleksiyondaki belgeye erişim
      final DocumentSnapshot gameSnapshot = await FirebaseFirestore.instance
          .collection('gameDataset')
          .doc(widget.nonactiveGameData['gameId'])
          .get();

      // Eğer belge var ise, iç koleksiyonunu sorgula
      if (gameSnapshot.exists) {
        // İç koleksiyondaki belgeleri sorgulama
        QuerySnapshot aboutSnapshot = await FirebaseFirestore.instance
            .collection('gameDataset')
            .doc(widget.nonactiveGameData['gameId'])
            .collection('about')
            .where('wordId',
                isEqualTo:
                    updatedGameData['wordId']) // `wordId` ile eşleşen belgeler
            .get();

        // Belge var ise işlem yap
        if (aboutSnapshot.docs.isNotEmpty) {
          for (var doc in aboutSnapshot.docs) {
            // Belgeyi güncelle
            await doc.reference.update(updatedGameData);
          }

          // Güncelleme başarılı olduğunda kullanıcıya geri bildirim verin
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Veriler başarıyla güncellendi."),
              backgroundColor: Colors.green,
            ),
          );

          // İlgili sayfaya yönlendirme
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(
                userData: widget.userData,
              ),
            ),
          );
        } else {
          print('İlgili belge bulunamadı.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Belge bulunamadı."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Ana belge bulunamadı.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ana belge bulunamadı."),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> editGames(BuildContext context) async {
    debugPrint("fonks çağ");

    final int initialValue = widget.nonactiveGameData['onay_durumu'];
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
                      DropdownButtonFormField<int>(
                        value: initialValue,
                        items: [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Text('0'),
                          ),
                          DropdownMenuItem<int>(
                            value: 1,
                            child: Text('1'),
                          ),
                        ],
                        onChanged: (int? value) {
                          setState(() {
                            widget.nonactiveGameData['onay_durumu'] = value!;
                          });
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
                          if (value == null) {
                            return 'Sınıf bilgisi boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final updatedGameData = {
                              'onay_durumu':
                                  widget.nonactiveGameData['onay_durumu'],
                            };
                            await updateGameData(updatedGameData, context);
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

  Future<void> deleteGame(BuildContext context) async {
    try {
      // Konu verilerini topics_archive tablosuna kaydet
      await FirebaseFirestore.instance
          .collection('gameDatasetArchive')
          .doc(widget.nonactiveGameData['wordId'])
          .set({
        'createdAt': widget.nonactiveGameData['createdAt'],
        'gameId': widget.nonactiveGameData['gameId'],
        'userId': widget.nonactiveGameData['userId'],
        'text': widget.nonactiveGameData['text'],
      });

      // Silinecek oyun verisini getir
      final DocumentSnapshot deletegameSnapshot = await FirebaseFirestore
          .instance
          .collection('gameDataset')
          .doc(widget.nonactiveGameData['gameId'])
          .get();

      if (deletegameSnapshot.exists) {
        // `wordId` ile eşleşen belgeleri sil
        await FirebaseFirestore.instance
            .collection('gameDataset')
            .doc(widget.nonactiveGameData['gameId'])
            .collection('about')
            .doc(widget.nonactiveGameData['wordId'])
            .delete();
      }

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kelime başarıyla silindi."),
          backgroundColor: Colors.green,
        ),
      );

      // Geri dön
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdminPage(userData: widget.userData)),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kelime silinirken bir hata oluştu."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(
      (widget.nonactiveGameData['createdAt'] as Timestamp).toDate(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Oyun Bilgileri"),
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
                        deleteGame(context);
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        debugPrint("tıklandi");
                        editGames(context);
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
                  'Eklenen Cümle  :',
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
                        ' ${widget.nonactiveGameData['text']}',
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
                  '${widget.nonactiveGameData['onay_durumu']} ',
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
                  '${_GameuserData['name']} ',
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
                  '${_GameuserData['surname']}',
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
                  ' ${_GameuserData['email']}',
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
                  ' ${_GameuserData['user_type']}',
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
                  ' ${widget.nonactiveGameData['user_id']}',
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