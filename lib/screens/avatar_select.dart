import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:neu_social/screens/profile_page.dart';

class AvatarSelect extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AvatarSelect({Key? key, required this.userData}) : super(key: key);

  @override
  State<AvatarSelect> createState() => _AvatarSelectState();
}

class _AvatarSelectState extends State<AvatarSelect> {
  int _selectedIndex = -1;
  String?
      selectedAvatarUrl; // Seçilen avatar URL'sini saklamak için bir değişken

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avatar Seç'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future:
                  _fetchAvatarUrls(), // Firebase Storage'dan avatar URL'lerini al
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(), // Yükleniyor göstergesi
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshot.error}'), // Hata durumunda
                  );
                } else if (snapshot.hasData) {
                  // Veri varsa
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 sütunlu bir grid
                      crossAxisSpacing: 8.0, // Sütunlar arası boşluk
                      mainAxisSpacing: 8.0, // Satırlar arası boşluk
                    ),
                    itemCount: snapshot.data!.length, // Avatar sayısı
                    itemBuilder: (context, index) {
                      String avatarUrl = snapshot.data![index]; // Avatar URL'si

                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index; // Update selected index
                              });
                              _selectAvatar(avatarUrl);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedIndex == index
                                      ? Color.fromARGB(255, 193, 20,
                                          20) // Pink border for selected item
                                      : const Color.fromARGB(255, 2, 10, 16),
                                  width: 3, // Kenarlık kalınlığı
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(avatarUrl), // Avatarı göster
                                backgroundColor: Colors
                                    .transparent, // Arka plan rengini şeffaf yap
                                radius: 20, // Dairenin yarıçapı
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('Veri bulunamadı'), // Veri yoksa
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 40.0, right: 16, left: 16),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 112, 169, 181),
                    side: BorderSide(
                        width: 1, color: Color.fromARGB(255, 73, 169, 210)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                      20,
                    ))),
                onPressed: () {
                  setState(() {
                    // FutureBuilder'ın yeniden çalışması için state'i güncelliyoruz
                    _updateUsersAvatarUrl();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(userData: widget.userData),
                      ),
                    ).then((_) {
                      // Sayfa değiştikten sonra sayfayı yenile
                      setState(() {});
                      // Snackbar göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Avatar güncellendi'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
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
                    'Güncelle',
                    style: TextStyle(fontSize: 16),
                  )
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateUsersAvatarUrl() async {
    try {
      if (selectedAvatarUrl != null) {
        // Seçilen avatar URL'si boş değilse işlemi gerçekleştir
        // Firebase Firestore'da 'users' koleksiyonunu referans al
        var usersCollection = FirebaseFirestore.instance.collection('users');

        // Mevcut kullanıcının belgesini al
        var userDoc = usersCollection.doc(widget.userData['user_id']);

        // Avatar URL'ini güncelle, 'avatarUrl' alanını yeni URL ile değiştir
        await userDoc.update({'avatar_image': selectedAvatarUrl});

        // Başarıyla güncellendiğini göster
        print('Avatar URL güncellendi: $selectedAvatarUrl');
      } else {
        print('Hata: Seçilen avatar URL boş.');
      }
    } catch (error) {
      // Hata durumunda hatayı yazdır
      print('Avatar URL güncellenirken hata oluştu: $error');
    }
  }

  Future<List<String>> _fetchAvatarUrls() async {
    List<String> avatarUrls = [];

    try {
      // Firestore veritabanında 'avatars' koleksiyonunu referans al
      var querySnapshot =
          await FirebaseFirestore.instance.collection('avatars').get();

      // Her belgeyi döngüye alarak avatar URL'lerini al
      querySnapshot.docs.forEach((doc) {
        // 'avatarUrl' alanından URL'yi al ve listeye ekle
        String? url = doc.data()['avatarUrl'];
        if (url != null) {
          avatarUrls.add(url);
        }
      });
    } catch (error) {
      print('Avatar URL alınamadı: $error');
    }

    return avatarUrls;
  }

  void _selectAvatar(String avatarUrl) {
    // Seçilen avatarı kullanmak için burada bir işlem yapabilirsiniz
    // Örneğin, kullanıcı profiline seçilen avatar URL'sini kaydedebilirsiniz
    setState(() {
      selectedAvatarUrl = avatarUrl;
    });
    print('Seçilen avatar URL: $avatarUrl');
  }
}
