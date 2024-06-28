import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neu_social/widgets/mizah_post.dart';

class MizahPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MizahPage({Key? key, required this.userData}) : super(key: key);

  Future<void> addMizahPost(BuildContext context) async {
    if (userData['user_id'] == '2') {
      try {
        String postId = FirebaseFirestore.instance.collection('mizah').doc().id;
        DocumentReference newPostRef =
            FirebaseFirestore.instance.collection('mizah').doc();

        DateTime currentDate = DateTime.now();
        Map<String, dynamic> postData = {
          'post_text': 'Buraya mizah içeriğini yazınız',
          'post_id':
              newPostRef.id, // Otomatik oluşturulan ID burada kullanılıyor.
          'user_id': userData['user_id'],
          'images': null,
          'post_likes': [],
          'date': currentDate,
        };

        await newPostRef.set(postData);

        try {
          _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
            content: Text('Mizah postu başarıyla eklendi.'),
            backgroundColor: Colors.green,
          ));
        } catch (e) {
          print('Failed to show SnackBar: $e');
        }
      } catch (e) {
        print("Error adding mizah post: $e");
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Sadece admin tarafından bu işlem yapılabilir.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> showAddMizahPostSheet(BuildContext context) async {
    String postText = '';
    XFile? imageFile;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      onChanged: (value) => postText = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mizah İçeriğini Yazınız',
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // background (button) color
                        foregroundColor:
                            Colors.white, // foreground (text) color
                      ),
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        imageFile = await _picker.pickImage(
                            source: ImageSource.gallery);
                        setModalState(() {});
                      },
                      child: Text('Galeriden Resim Yükle'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 5, 124, 58), // background (button) color
                        foregroundColor:
                            Colors.white, // foreground (text) color
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        if (imageFile != null && postText.isNotEmpty) {
                          String fileName =
                              'files/${DateTime.now().millisecondsSinceEpoch}_${imageFile!.name}';
                          UploadTask uploadTask = FirebaseStorage.instance
                              .ref(fileName)
                              .putFile(File(imageFile!.path));
                          TaskSnapshot snapshot = await uploadTask;
                          String imageUrl = await snapshot.ref.getDownloadURL();

                          DateTime currentDate = DateTime.now();
                          Map<String, dynamic> postData = {
                            'post_text': postText,
                            'images': imageUrl,
                            'date': currentDate,
                            'user_id': userData['user_id'],
                            'post_likes': [],
                          };
                          DocumentReference newPostRef = await FirebaseFirestore
                              .instance
                              .collection('mizah')
                              .add(postData);

// Get the ID of the newly added document and update the 'post_id' field
                          String postId = newPostRef.id;
                          await newPostRef.update({'post_id': postId});

                          // Show success message
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text('Mizah postu başarıyla eklendi.'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // BottomSheet'i kapat
                        } else {
                          // Eğer postText boşsa veya resim seçilmediyse kullanıcıya bir hata mesajı göster.
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Lütfen bir metin girin ve bir resim seçin.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Gönderiyi Kaydet'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("mizah")
                  .orderBy("date",
                      descending: true) // Tarihe göre azalan sırada
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return MizahPost(
                          message: post['post_text'],
                          userData: userData,
                          postId: post.id, // Use Firestore document ID
                          imageUrl: post['images'],
                          likes: List<String>.from(post['post_likes'] ?? []),
                          date: post['date']);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userData['user_id'] == '2' || userData['user_id'] == '1') {
            showAddMizahPostSheet(context);
          } else {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Sadece admin tarafından bu işlem yapılabilir.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Icon(
          Icons.add,
          color: const Color.fromARGB(255, 4, 4, 2),
        ),
        backgroundColor: Color.fromARGB(131, 130, 170, 202),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
