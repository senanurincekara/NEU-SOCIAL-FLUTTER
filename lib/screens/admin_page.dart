import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/screens/adminDetailPages/anket_detail_page.dart';
import 'package:neu_social/screens/adminDetailPages/games_detail_page.dart';
import 'package:neu_social/screens/adminDetailPages/new_user_detail_page.dart';
import 'package:neu_social/screens/adminDetailPages/topics_detail_page.dart';
import 'package:neu_social/screens/adminDetailPages/users_detail_page.dart';
import 'package:neu_social/widgets/bottomNavigationBar.dart';

import 'adminDetailPages/non_active_comments_detail_page.dart';

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AdminPage({Key? key, required this.userData}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _selectedOption = 'AKTİF KULLANICILAR';
  List<String> listItem = [
    "AKTİF KULLANICILAR",
    "YENİ KULLANICILAR",
    "AKTİF TOPİKLER",
    "YENİ TOPİKLER",
    "AKTİF YORUMLAR",
    "YENİ YORUMLAR",
    "ANKETLER",
    "HİKAYE OYUNU"
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _activeUsers = [];
  List<Map<String, dynamic>> _nonactiveUsers = [];
  List<Map<String, dynamic>> _activeTopics = [];
  List<Map<String, dynamic>> _nonactiveTopics = [];
  List<Map<String, dynamic>> _activeSurveys = [];
  List<Map<String, dynamic>> _nonactiveGames = [];
  List<Map<String, dynamic>> _nonactiveComments = [];
  List<Map<String, dynamic>> _activeComments = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveUsers();
    _fetchNonActiveUsers();
    _fetchActiveTopics();
    _fetchNewTopics();
    _fetchActiveSurveys();
    _fetchNonActiveGames();
    _fetchnonactiveComments();
    _fetchactiveComments();
  }

  Future<void> AddSurveyToTheDatabase(
      String description, String urlAddress) async {
    String anketId = FirebaseFirestore.instance.collection('anketler').doc().id;
    DateTime currentDate = DateTime.now();
    Map<String, dynamic> anketData = {
      'anket_id': anketId,
      'anket_url': urlAddress,
      'text': description,
      'date': currentDate,
    };
    await FirebaseFirestore.instance
        .collection('anketler')
        .doc(anketId)
        .set(anketData);
  }

  Future<void> AddSurvey(BuildContext context) async {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController urlAddressController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height * (1.75 / 5),
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
                        controller: descriptionController,
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
                        controller: urlAddressController,
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
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String description = descriptionController.text;
                            String urlAddress = urlAddressController.text;
                            await AddSurveyToTheDatabase(
                                description, urlAddress);
                            Navigator.pop(context); // Bottom sheet'i kapat
                            setState(() {});
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

  void _fetchActiveSurveys() {
    _firestore.collection('anketler').get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _activeSurveys = [];
          snapshot.docs.forEach((doc) {
            _activeSurveys.add(doc.data() as Map<String, dynamic>);
          });
        });
      }
    }).catchError((error) {
      print('Error fetching active Surveys: $error');
    });
  }

  void _fetchnonactiveComments() {
    _firestore.collection('topics').get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((document) {
          _fetchnonActiveCommentsForDocument(document);
        });
      } else {
        print('No documents found in the collection');
      }
    }).catchError((error) {
      print('Error fetching documents: $error');
    });
  }

  void _fetchnonActiveCommentsForDocument(DocumentSnapshot document) {
    String documentId = document.id;
    _firestore
        .collection('topics')
        .doc(documentId)
        .collection('comments')
        .where('admin_onay', isEqualTo: '0')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic> mainCommentDocumentData =
                document.data() as Map<String, dynamic>;
            Map<String, dynamic> nonActiveCommentData =
                doc.data() as Map<String, dynamic>;

            // Merging both maps
            Map<String, dynamic> combinedData = {};
            combinedData.addAll(mainCommentDocumentData);
            combinedData.addAll(nonActiveCommentData);

            _nonactiveComments.add(combinedData);
          });
        });

        print('Data found for document $documentId');
      } else {
        print('No non-active games found for document $documentId');
      }
    }).catchError((error) {
      print('Error fetching non-active games for document $documentId: $error');
    });
  }

  void _fetchactiveComments() {
    _firestore.collection('topics').get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((document) {
          _fetchActiveCommentsForDocument(document);
        });
      } else {
        print('No documents found in the collection');
      }
    }).catchError((error) {
      print('Error fetching documents: $error');
    });
  }

  void _fetchActiveCommentsForDocument(DocumentSnapshot document) {
    String documentId = document.id;
    _firestore
        .collection('topics')
        .doc(documentId)
        .collection('comments')
        .where('admin_onay', isEqualTo: '1')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic> mainactiveCommentDocumentData =
                document.data() as Map<String, dynamic>;
            Map<String, dynamic> ActiveCommentData =
                doc.data() as Map<String, dynamic>;

            // Merging both maps
            Map<String, dynamic> combinedData2 = {};
            combinedData2.addAll(mainactiveCommentDocumentData);
            combinedData2.addAll(ActiveCommentData);

            _activeComments.add(combinedData2);
          });
        });

        print('Data found for document $documentId');
      } else {
        print('No active comments found for document $documentId');
      }
    }).catchError((error) {
      print('Error fetching active comments for document $documentId: $error');
    });
  }

  void _fetchActiveUsers() {
    _firestore
        .collection('users')
        .where('onay_durumu', isEqualTo: '1')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _activeUsers = [];
          snapshot.docs.forEach((doc) {
            _activeUsers.add(doc.data() as Map<String, dynamic>);
          });
        });
      }
    }).catchError((error) {
      print('Error fetching active users: $error');
    });
  }

  void _fetchNonActiveUsers() {
    _firestore
        .collection('users')
        .where('onay_durumu', isEqualTo: '0')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _nonactiveUsers = [];
          snapshot.docs.forEach((doc) {
            _nonactiveUsers.add(doc.data() as Map<String, dynamic>);
          });
        });
      }
    }).catchError((error) {
      print('Error fetching active users: $error');
    });
  }

  void _fetchNonActiveGames() {
    _firestore.collection('gameDataset').get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((document) {
          _fetchNonActiveGamesForDocument(document);
        });
      } else {
        print('No documents found in the collection');
      }
    }).catchError((error) {
      print('Error fetching documents: $error');
    });
  }

  void _fetchNonActiveGamesForDocument(DocumentSnapshot document) {
    String documentId = document.id;
    _firestore
        .collection('gameDataset')
        .doc(documentId)
        .collection('about')
        .where('onay_durumu', isEqualTo: 0)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic> mainDocumentData =
                document.data() as Map<String, dynamic>;
            Map<String, dynamic> nonActiveGameData =
                doc.data() as Map<String, dynamic>;

            // Merging both maps
            Map<String, dynamic> combinedData = {};
            combinedData.addAll(mainDocumentData);
            combinedData.addAll(nonActiveGameData);

            _nonactiveGames.add(combinedData);
          });
        });

        print('Data found for document $documentId');
      } else {
        print('No non-active games found for document $documentId');
      }
    }).catchError((error) {
      print('Error fetching non-active games for document $documentId: $error');
    });
  }

  void _fetchActiveTopics() {
    _firestore
        .collection('topics')
        .where('admin_onay', isEqualTo: '1')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _activeTopics = [];
          snapshot.docs.forEach((doc) {
            _activeTopics.add(doc.data() as Map<String, dynamic>);
          });
        });
      }
    }).catchError((error) {
      print('Error fetching active users: $error');
    });
  }

  void _fetchNewTopics() {
    _firestore
        .collection('topics')
        .where('admin_onay', isEqualTo: '0')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _nonactiveTopics = [];
          snapshot.docs.forEach((doc) {
            _nonactiveTopics.add(doc.data() as Map<String, dynamic>);
          });
        });
      }
    }).catchError((error) {
      print('Error fetching active users: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "ADMİN PANEL",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 1, 0, 31),
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        // HomePage(userData: userData), // userData parametresini sağla
                        MyBottomNavBar(userData: widget.userData)),
              );
            }),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Color.fromARGB(255, 4, 0, 55), width: 1),
              ),
              child: DropdownButton<String>(
                hint: Text("seçiniz"),
                icon: Icon(Icons.arrow_drop_down),
                iconEnabledColor: const Color.fromARGB(255, 8, 0, 0),
                iconSize: 24,
                isExpanded: true,
                underline: SizedBox(),
                value: _selectedOption,
                onChanged: (newValue) {
                  setState(() {
                    _selectedOption = newValue ?? '';
                  });
                },
                items: listItem.map<DropdownMenuItem<String>>((valueItem) {
                  return DropdownMenuItem<String>(
                      value: valueItem, child: Text(valueItem));
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _buildListView(), // ListView'i başka bir metoda taşıdık
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    switch (_selectedOption) {
      case 'AKTİF KULLANICILAR':
        return _buildActiveUsersList();
      case 'YENİ KULLANICILAR':
        return _buildNewUsersList();
      case 'AKTİF TOPİKLER':
        return _buildActiveTopicsList();
      case 'YENİ TOPİKLER':
        return _buildNewTopicsList();
      case 'AKTİF YORUMLAR':
        return _buildActiveCommentsList();
      case 'YENİ YORUMLAR':
        return _buildNewCommentsList();
      case 'ANKETLER':
        return _buildActiveSurveyList();
      case 'HİKAYE OYUNU':
        return _buildGameList();
      default:
        return Container(); // Varsayılan olarak boş bir container döndür
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    var formattedDate = DateFormat('dd/MM/yyyy').format(date);
    var formattedTime = DateFormat('HH:mm').format(date);
    return '$formattedDate $formattedTime';
  }

  Widget _buildGameList() {
    // Sort the _nonactiveGames list by the createdAt field
    _nonactiveGames.sort((a, b) {
      Timestamp aTimestamp = a['createdAt'] as Timestamp;
      Timestamp bTimestamp = b['createdAt'] as Timestamp;
      return aTimestamp.compareTo(bTimestamp); // For descending order
    });

    return ListView.builder(
      itemCount: _nonactiveGames.length,
      itemBuilder: (context, index) {
        var game = _nonactiveGames[index];
        var createdAtTimestamp = game['createdAt'] as Timestamp;
        var formattedCreatedAt = formatTimestamp(createdAtTimestamp);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  '${game['name']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  formattedCreatedAt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamesDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        nonactiveGameData: _nonactiveGames[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 66, 64, 64))),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveUsersList() {
    // AKTİF KULLANICILAR listesi oluşturulacak widget
    return ListView.builder(
      itemCount: _activeUsers.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Adjust padding as needed
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  '${_activeUsers[index]['name']} ${_activeUsers[index]['surname']} ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${_activeUsers[index]['school_number']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsersDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        activeUserData: _activeUsers[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 66, 64, 64))),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveSurveyList() {
    // AKTİF KULLANICILAR listesi oluşturulacak widget
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          AddSurvey(context);
        },
        child: Icon(
          Icons.add,
          color: const Color.fromARGB(255, 4, 4, 2),
        ),
        backgroundColor: Color.fromARGB(131, 130, 170, 202),
      ),
      body: ListView.builder(
        itemCount: _activeSurveys.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16), // Gerektiğinde dolgu ayarlayın
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 20, right: 20),
                  title: Text(
                    '${_activeSurveys[index]['text']}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnketDetailPage(
                          userData:
                              widget.userData, // Ana sayfadaki userData bilgisi
                          activeSurveyData: _activeSurveys[
                              index], // Seçilen aktif kullanıcı bilgisi
                        ),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: const Color.fromARGB(255, 66, 64, 64))),
                  tileColor: Color.fromARGB(255, 208, 224, 240),
                ),
              ),
              Divider(
                color: Color.fromARGB(255, 251, 251, 251),
                thickness: 0,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewUsersList() {
    // AKTİF KULLANICILAR listesi oluşturulacak widget
    return ListView.builder(
      itemCount: _nonactiveUsers.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Adjust padding as needed
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  '${_nonactiveUsers[index]['name']} ${_nonactiveUsers[index]['surname']} ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${_nonactiveUsers[index]['school_number']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => newUsersDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        activeUserData: _nonactiveUsers[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 66, 64, 64))),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveTopicsList() {
    // AKTİF KULLANICILAR listesi oluşturulacak widget
    return ListView.builder(
      itemCount: _activeTopics.length,
      itemBuilder: (context, index) {
        final formattedDate = DateFormat('dd.MM.yyyy').format(
          (_activeTopics[index]['date'] as Timestamp).toDate(),
        );
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  'Tarih: $formattedDate ',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 35, 17, 0)),
                ),
                subtitle: Text(
                  '${_activeTopics[index]['contents']}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 50, 19, 8)),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicsDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        activeTopicData: _activeTopics[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Color.fromARGB(255, 61, 61, 61),
                  ),
                ),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewTopicsList() {
    return ListView.builder(
      itemCount: _nonactiveTopics.length,
      itemBuilder: (context, index) {
        final formattedDate = DateFormat('dd.MM.yyyy').format(
          (_nonactiveTopics[index]['date'] as Timestamp).toDate(),
        );
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              // Adjust padding as needed
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  'Tarih: $formattedDate ',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 35, 17, 0)),
                ),
                subtitle: Text(
                  '${_nonactiveTopics[index]['contents']}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 50, 19, 8)),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicsDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        activeTopicData: _nonactiveTopics[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Color.fromARGB(255, 61, 61, 61),
                  ),
                ),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveCommentsList() {
    // Sort the _nonactiveGames list by the createdAt field
    _activeComments.sort((a, b) {
      Timestamp aTimestamp = a['date'] as Timestamp;
      Timestamp bTimestamp = b['date'] as Timestamp;
      return aTimestamp.compareTo(bTimestamp); // For descending order
    });

    return ListView.builder(
      itemCount: _activeComments.length,
      itemBuilder: (context, index) {
        var comments = _activeComments[index];
        var createdAtTimestamp = comments['date'] as Timestamp;
        var formattedCreatedAt = formatTimestamp(createdAtTimestamp);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  getFirst20Characters(comments['comments_text']),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  formattedCreatedAt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NonActiveCommentsDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        nonactiveCommentData: _activeComments[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 66, 64, 64))),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }

  String getFirst20Characters(String text) {
    if (text.length > 38) {
      return text.substring(0, 38) + '...';
    }
    return text;
  }

  Widget _buildNewCommentsList() {
    // Sort the _nonactiveGames list by the createdAt field
    _nonactiveComments.sort((a, b) {
      Timestamp aTimestamp = a['date'] as Timestamp;
      Timestamp bTimestamp = b['date'] as Timestamp;
      return aTimestamp.compareTo(bTimestamp); // For descending order
    });

    return ListView.builder(
      itemCount: _nonactiveComments.length,
      itemBuilder: (context, index) {
        var comments = _nonactiveComments[index];
        var createdAtTimestamp = comments['date'] as Timestamp;
        var formattedCreatedAt = formatTimestamp(createdAtTimestamp);
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 20, right: 20),
                title: Text(
                  getFirst20Characters(comments['comments_text']),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  formattedCreatedAt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NonActiveCommentsDetailPage(
                        userData:
                            widget.userData, // Ana sayfadaki userData bilgisi
                        nonactiveCommentData: _nonactiveComments[
                            index], // Seçilen aktif kullanıcı bilgisi
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 66, 64, 64))),
                tileColor: Color.fromARGB(255, 208, 224, 240),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 251, 251, 251),
              thickness: 0,
            ),
          ],
        );
      },
    );
  }
}
