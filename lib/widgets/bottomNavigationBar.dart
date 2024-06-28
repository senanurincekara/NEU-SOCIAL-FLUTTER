import 'package:flutter/material.dart';
import 'package:neu_social/screens/admin_page.dart';
import 'package:neu_social/screens/etkinlik_page.dart';
import 'package:neu_social/screens/feedback_page.dart';
import 'package:neu_social/screens/game_page.dart';
import 'package:neu_social/screens/home_page.dart';
import 'package:neu_social/screens/job_page.dart';
import 'package:neu_social/screens/mizah_page.dart';
import 'package:neu_social/screens/profile_page.dart';
import 'package:neu_social/screens/project_page.dart';
import 'package:neu_social/screens/signin_screen.dart';

class MyBottomNavBar extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MyBottomNavBar({Key? key, required this.userData}) : super(key: key);

  @override
  State<MyBottomNavBar> createState() => _MyButtomNavBarState();
}

class _MyButtomNavBarState extends State<MyBottomNavBar> {
  int myCurrentIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(userData: widget.userData),
      EtkinlikPage(userData: widget.userData),
      MizahPage(userData: widget.userData),
      JobPage(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 216, 248, 255),
        title: Text('NEÜ SOSYAL'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Color.fromARGB(255, 0, 1, 33).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(5, 10))
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
              // backgroundColor: Colors.transparent,
              selectedItemColor: Colors.redAccent,
              unselectedItemColor: Colors.black,
              currentIndex: myCurrentIndex,
              onTap: (index) {
                setState(() {
                  myCurrentIndex = index % pages.length;
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.lightbulb), label: "Topik"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_rounded),
                    label: "Etkinlikler"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.sentiment_very_satisfied_outlined),
                    label: "Mizah"),
                BottomNavigationBarItem(icon: Icon(Icons.work), label: "İş"),
              ]),
        ),
      ),
      body: pages[myCurrentIndex],
      drawer: Drawer(
        child: Container(
          color: Color.fromARGB(255, 226, 253, 255),
          child: ListView(
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 226, 253, 255),
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/drawer.png",
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                    // Stack children go here
                    ),
              ),
              SizedBox(
                height: 30,
              ),
              ListTile(
                leading: Icon(Icons.person_2_outlined),
                title: Text(
                  "P r o f i l",
                  style: TextStyle(fontSize: 17),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  _profilePage();
                },
              ),
              ListTile(
                  leading: Icon(Icons.question_answer),
                  title: Text(
                    "A n k e t l e r",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _feedbackPage();
                  }),
              ListTile(
                  leading: Icon(Icons.school),
                  title: Text(
                    "P r o j e l e r",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _ProjectPage();
                  }),
              ListTile(
                  leading: Icon(Icons.games_outlined),
                  title: Text(
                    "E ğ l e n c e",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _GamePage();
                  }),
              ListTile(
                  leading: Icon(Icons.contact_mail),
                  title: Text(
                    "A d m i n",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    if (widget.userData['user_id'] == '1') {
                      Navigator.pop(context);
                      _AdminPage();
                    } else {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              "UYARI !!",
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 73, 7, 2),
                                  fontSize: 25),
                            ),
                            content: Text(
                              "Bu sayfaya erişim sadece admin tarafındandır!",
                              style: TextStyle(
                                  color: Color.fromARGB(199, 0, 0, 0),
                                  fontSize: 18),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Tamam",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 6, 129, 13)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }),
              ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Ç I K I Ş",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (e) => const SignInScreen(),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _profilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userData: widget.userData),
      ),
    );
  }

  void _GamePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(userData: widget.userData),
      ),
    );
  }

  void _AdminPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPage(userData: widget.userData),
      ),
    );
  }

  void _ProjectPage() {
    // Push a new route for the ProjectPage without removing the current state
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectPage(userData: widget.userData),
      ),
    );
  }

  void _feedbackPage() {
    // Push a new route for the FeedbackPage without removing the current state
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => feedbackPage(userData: widget.userData),
      ),
    );
  }
}
