import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectDetailPage extends StatelessWidget {
  final String projectName;
  final String projectText;
  final String prejectUserId;

  const ProjectDetailPage({
    Key? key,
    required this.projectName,
    required this.projectText,
    required this.prejectUserId,
  }) : super(key: key);

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
              "DETAYLI ÇALIŞALIM",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 3, 3, 3),
                fontSize: 20.0,
              ),
            ),
            Icon(
              Icons.insert_emoticon_outlined,
              size: 28,
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _mainIcon(),
            _Inputs(),
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
        'assets/images/projects.png', // Resmin dosya yolunu belirt
        fit: BoxFit.cover, // Resmi container'a sığdır
      ),
    );
  }

  Widget _Inputs() {
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
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(prejectUserId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      if (!snapshot.hasData) {
                        return Text("User not found");
                      }
                      final ProjectuserData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final userFullName =
                          '${ProjectuserData['name']} ${ProjectuserData['surname']}';

                      final userAvatarUrl = ProjectuserData['avatar_image'];
                      return Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Proje sahibi: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text("$userFullName",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Times New Roman')),
                            ],
                          ),
                          // CircleAvatar(
                          //   radius: 30.0,
                          //   backgroundImage: NetworkImage(userAvatarUrl),
                          //   backgroundColor: Colors.transparent,
                          // )
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Project Adı:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    projectName,
                    style:
                        TextStyle(fontSize: 16, fontFamily: 'Times New Roman'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Proje Detayı:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    projectText,
                    style:
                        TextStyle(fontSize: 16, fontFamily: 'Times New Roman'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
