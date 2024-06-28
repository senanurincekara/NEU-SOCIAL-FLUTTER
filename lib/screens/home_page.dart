import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neu_social/screens/topics_detail_page.dart';
import 'package:neu_social/widgets/wall_post.dart';

final textController = TextEditingController();

class HomePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomePage({Key? key, required this.userData}) : super(key: key);

  void signUserOut() async {
    try {
      // Perform sign-out operation
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future<void> postMessage(BuildContext context) async {
    if (textController.text.isNotEmpty) {
      try {
        String topicId =
            FirebaseFirestore.instance.collection('topics').doc().id;
        DateTime currentDate = DateTime.now();
        Map<String, dynamic> topicData = {
          'user_id': userData['user_id'],
          'topics_id': topicId,
          'like_number': [],
          'contents': textController.text,
          'admin_onay': '0',
          'date': currentDate,
          'admin_id': ''
        };

        await FirebaseFirestore.instance
            .collection('topics')
            .doc(topicId)
            .set(topicData);

        textController.clear();

        // Gönderi başarıyla post edildiğinde SnackBar göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Postunuz onaydan geçmek üzere alınmıştır'),
            backgroundColor: Colors.green, // SnackBar'ın arka plan rengi
          ),
        );
      } catch (e) {
        print("Error posting message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("topics")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      if (post["admin_onay"] == '1') {
                        // admin_onay == 1 olanları filtrele
                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('topics')
                              .doc(post['topics_id'])
                              .collection('comments')
                              .get(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopicDetailPage(
                                        topicId: post['topics_id'],
                                        userData: userData,
                                      ),
                                    ),
                                  );
                                },
                                child: WallPost(
                                  message: post['contents'],
                                  user: post['user_id'],
                                  time: post['date'],
                                  userData: userData,
                                  postId: post['topics_id'],
                                  likes: List<String>.from(
                                      post['like_number'] ?? []),
                                  commentCount: snapshot.data!.docs.length,
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return Container(); // admin_onay == 1 olmayanları gösterme
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
                      hintText: "Post Yazınız",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => postMessage(context),
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
