import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/screens/home_page.dart';

class TopicDetailPage extends StatelessWidget {
  final String topicId;
  final Map<String, dynamic> userData;
  const TopicDetailPage(
      {Key? key, required this.topicId, required this.userData})
      : super(key: key);

  Future<void> postComment(BuildContext context) async {
    if (textController.text.isNotEmpty) {
      try {
        Map<String, dynamic> commentData = {
          'comments_text': textController.text,
          'admin_onay': '0',
          'date': DateTime.now(),
          'user_id': userData['user_id'],
        };

        await FirebaseFirestore.instance
            .collection('topics')
            .doc(topicId)
            .collection('comments')
            .add(commentData);

        textController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumunuz onaydan geçmek üzere alınmıştır.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print("Error posting comment: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Düşünelim Tartışalım'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("topics")
                  .doc(topicId)
                  .collection("comments")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'K O N U - - -',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 118, 4, 4)),
                                  ),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection("topics")
                                        .doc(topicId)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final topicData = snapshot.data!;
                                        final formattedDate =
                                            DateFormat('dd.MM.yyyy').format(
                                                topicData['date'].toDate());
                                        return Text(
                                          'Tarih: $formattedDate',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            color:
                                                Color.fromARGB(255, 2, 23, 55),
                                          ),
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("topics")
                                    .doc(topicId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final topicData = snapshot.data!;
                                    return Text(
                                      topicData['contents'],
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Color.fromARGB(255, 2, 23, 55),
                                      ),
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        final comment = snapshot.data!.docs[index - 1];
                        if (comment['admin_onay'] == '1') {
                          return Container(
                            margin: EdgeInsets.all(30),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 229, 242, 246),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['comments_text'],
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Admin onay durumu: ${comment['admin_onay']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }
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
          Padding(
            padding: const EdgeInsets.only(bottom: 100, right: 25, left: 55),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Yorumunuzu Yazınız",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => postComment(context),
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
