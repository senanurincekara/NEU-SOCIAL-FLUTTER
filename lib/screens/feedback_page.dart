import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/widgets/bottomNavigationBar.dart';
import 'package:neu_social/widgets/feedback_post.dart';
import 'package:vector_math/vector_math.dart' as math;

class feedbackPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final TextEditingController _feedbackController = TextEditingController();

  feedbackPage({Key? key, required this.userData}) : super(key: key);

  Future<void> _saveFeedback(String feedbackText) async {
    // Firestore veritabanına geri dönüşü ekleme
    DocumentReference feedbackRef =
        FirebaseFirestore.instance.collection('feedbacks').doc();

    // Geri dönüş bilgilerini Firestore'a ekleme
    await feedbackRef.set({
      'feedback_id':
          feedbackRef.id, // Oluşturulan ID'yi feedback_id olarak atama
      'date': DateTime.now(),
      'user_id': userData['user_id'],
      'feedback_text': feedbackText,
    });

    // Geri dönüş metnini temizleme
    _feedbackController.clear();
  }

  void _openCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Geri Dönüşünüz İçin Teşekkür Ederiz !',
            style: TextStyle(
                fontSize: 25,
                fontFamily: 'Times New Roman',
                color: Color.fromARGB(221, 0, 2, 40)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/feedback.png', // Replace with your image path
                width: 300, // Adjust image width as needed
                height: 400,
              ),
              SizedBox(height: 16), // Adjust spacing as needed
              Text(
                'Zaman ayırıp bizimle paylaştığınız fikirleri değerlendirmek için sabırsızlanıyoruz.',
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
                  MaterialPageRoute(
                      builder: (context) => feedbackPage(userData: userData)),
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

  void _openCustomDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Fikirlerinizi dinlemek isteriz!',
            style: TextStyle(
                fontSize: 25,
                fontFamily: 'Times New Roman',
                color: Color.fromARGB(221, 0, 2, 40)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/feedback.png', // Replace with your image path
                width: 300, // Adjust image width as needed
                height: 400,
              ),
              SizedBox(height: 16), // Adjust spacing as needed
              Text(
                'Daha iyi bir sosyalleşme platformu yaratabilmemiz için zaman ayırıp bizimle fikirlerinizi paylaşırsanız çok mutlu oluruz ',
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
                  MaterialPageRoute(
                      builder: (context) => feedbackPage(userData: userData)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      appBar: AppBar(
        title: Text(
          "ANKETLER",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 3, 3, 3),
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 216, 248, 255),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyBottomNavBar(userData: userData)),
              );
            }),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 350,
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("anketler")
                            .orderBy("date", descending: true)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final post = snapshot.data!.docs[index];
                                // Koşul buraya gelecek
                                return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('anketler')
                                      .doc(post['anket_id'])
                                      .get(),
                                  builder: (context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      return InkWell(
                                        onTap: () {
                                          // Geri bildirim detaylarını gösterme
                                        },
                                        child: FeedbackPost(
                                            text: post['text'],
                                            time: post['date'],
                                            anket_url: post['anket_url']),
                                      );
                                    }
                                  },
                                );
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
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "GERİ DÖNÜŞ ",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ariel'),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.feedback_outlined,
                    color: Color.fromARGB(255, 18, 4, 9),
                    size: 30.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                ],
              ),
              Container(
                height: 180,
                // color: Colors.amber,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _feedbackController,
                        decoration: InputDecoration(
                            hintText:
                                'Uygulamamız ile ilgili geri dönüşlerinizi dinlemek isteriz',
                            border: OutlineInputBorder()),
                        maxLines: 5,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8, top: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.deepPurpleAccent,
                      onPressed: () {
                        debugPrint("Butona tıklandı");
                        if (_feedbackController.text.isNotEmpty) {
                          _saveFeedback(_feedbackController.text);
                          _openCustomDialog(context);
                        } else {
                          _openCustomDialog2(context);
                        }
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      tooltip: 'Artım',
                      child: Icon(Icons.insert_emoticon),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
