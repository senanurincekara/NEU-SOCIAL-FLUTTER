//hikaye eklemek

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoryDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot storyData;
  final Map<String, dynamic> userData;
  const StoryDetailPage(
      {Key? key, required this.storyData, required this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 216, 248, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Hikaye Zamanı",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 3, 3, 3),
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showAddStoryGame(context);
        },
        child: Icon(
          Icons.add,
          color: const Color.fromARGB(255, 4, 4, 2),
        ),
        backgroundColor: Color.fromARGB(131, 130, 170, 202),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _mainIcon(),
            _Inputs(storyData: storyData),
          ],
        ),
      ),
    );
  }

  Widget _mainIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 216, 248, 255), // Arka plan rengi
      ),
      child: Image.asset(
        'assets/images/story.png', // Resmin dosya yolunu belirt
        fit: BoxFit.cover, // Resmi container'a sığdır
      ),
    );
  }

  Widget _Inputs({required QueryDocumentSnapshot storyData}) {
    return Flexible(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // color: Colors.amber,
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('gameDataset')
                        .doc(storyData.id)
                        .collection('about')
                        .where('onay_durumu', isEqualTo: 1)
                        .orderBy('createdAt', descending: false)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Tüm belgelerin içeriklerini birleştir
                      final storyContent = snapshot.data!.docs
                          .map((doc) => doc['text'])
                          .join(' ');

                      return Text(
                        storyContent,
                        style: TextStyle(fontSize: 18.0),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Hikayemize ortak olduğunuz için teşekkürler !',
            style: TextStyle(
                fontSize: 25,
                fontFamily: 'Times New Roman',
                color: Color.fromARGB(221, 0, 2, 40)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/robotstory.png',
                width: 300,
                height: 400,
              ),
              SizedBox(height: 16),
              Text(
                'Onay sürecinden geçtikten sonra yayınlanacaktır :) .',
                style: TextStyle(
                    fontFamily: 'Ariel',
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(221, 0, 2, 40)),
              ),
            ],
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a, b) => StoryDetailPage(
                        userData: userData, storyData: storyData),
                  ),
                );
              },
              child: Icon(
                Icons.add_task_outlined,
                size: 30,
              ),
              style: OutlinedButton.styleFrom(
                shadowColor: const Color.fromARGB(255, 105, 187, 255),
                shape: CircleBorder(),
                padding: EdgeInsets.all(14),
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> showAddStoryGame(BuildContext context) async {
    String text = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Yeni Hikaye Ekle',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Hikaye Metni',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    text = value;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(70),
                  ],
                  maxLines: 3,
                ),
                SizedBox(height: 8.0),
                Text(
                  'Kalan karakter: ${70 - text.length}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (text.isNotEmpty) {
                      // Firestore'a yeni hikaye ekle
                      await FirebaseFirestore.instance
                          .collection('gameDataset')
                          .doc(storyData.id)
                          .collection('about')
                          .add({
                        'onay_durumu': 0,
                        'text': text,
                        'createdAt': Timestamp.now(),
                        'userId': userData['user_id'],
                        'gameId': storyData.id,
                      }).then((DocumentReference docRef) {
                        docRef.update({
                          'wordId': docRef.id,
                        });
                      });
                      Navigator.pop(context);
                      _openCustomDialog(context); // Modal'ı kapat
                    }
                  },
                  child: Text('Ekle'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
