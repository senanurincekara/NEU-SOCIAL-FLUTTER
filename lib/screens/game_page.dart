import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:neu_social/game_detail_page.dart';
import 'package:neu_social/widgets/bottomNavigationBar.dart';

class GamePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const GamePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0F7FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xffB2EBF2), const Color(0xffE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
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
                  Icon(
                    Icons.insert_emoticon_outlined,
                    size: 28,
                  ),
                  SizedBox(
                    width: 170,
                  ),
                  Text(
                    'Bu hikayeyi',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 22,
                      color: Color.fromARGB(255, 2, 7, 54),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, right: 25),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Beraber yazalım mı ?',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 22,
                        color: Color.fromARGB(255, 2, 7, 54),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Her birimiz sırayla bir cümle ekleyerek unutulmaz bir hikaye yaratacağız. Siz de bu eğlenceli oyunumuzda bize katılın <3 ',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 15,
                        color: Color.fromARGB(255, 2, 7, 54),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('gameDataset')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Hata: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("Henüz hikaye yok."));
                    }

                    final stories = snapshot.data!.docs;

                    return Swiper(
                      itemCount: stories.length,
                      itemWidth: MediaQuery.of(context).size.width - 2 * 64,
                      layout: SwiperLayout.STACK,
                      pagination: SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                            activeSize: 20, space: 8),
                      ),
                      itemBuilder: (context, index) {
                        final storyData = stories[index];
                        final storyName = storyData['name'];
                        final storyImage = 'assets/images/game.png';

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) => StoryDetailPage(
                                    userData: widget.userData,
                                    storyData: storyData),
                              ),
                            );
                          },
                          child: Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  SizedBox(height: 100),
                                  Card(
                                    elevation: 8,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 100),
                                          Text(
                                            storyName,
                                            style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 44,
                                              color: const Color(0xff47455f),
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            'Hikaye',
                                            style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontSize: 23,
                                              color: const Color(0xff47455f),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(height: 32),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                'Devamını Oku',
                                                style: TextStyle(
                                                  fontFamily: 'Avenir',
                                                  fontSize: 18,
                                                  color:
                                                      const Color(0xff47455f),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              Icon(Icons.arrow_forward_ios,
                                                  color:
                                                      const Color(0xff47455f)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Positioned(
                                top: 0,
                                left: 55,
                                child: Hero(
                                  tag: storyData.id,
                                  child: Image.asset(
                                    storyImage,
                                    height: 180,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
