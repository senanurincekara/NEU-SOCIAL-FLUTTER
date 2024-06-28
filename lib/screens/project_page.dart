import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neu_social/screens/addProjectPage/add_project_page.dart';
import 'package:neu_social/screens/projects_detail_page.dart';
import 'package:neu_social/widgets/bottomNavigationBar.dart';
import 'package:neu_social/widgets/project_posts.dart';

class ProjectPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProjectPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  TextEditingController _searchController = TextEditingController();

  void getMatch(String searchText) {
    setState(() {
      _filteredProjects = _projectsList
          .where((project) => project['proje_ad']
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void clearSearch() {
    setState(() {
      _searchController.text = "";
      _filteredProjects =
          _projectsList; // Arama sıfırlandığında, tüm projeleri göster
    });
  }

  List<Map<String, dynamic>> _projectsList = []; // Tüm projeleri tutacak liste
  List<Map<String, dynamic>> _filteredProjects =
      []; // Arama sonuçlarını tutacak liste

  @override
  void initState() {
    super.initState();
    // Firestore'dan projeleri al ve _projectsList'i güncelle
    FirebaseFirestore.instance
        .collection("projeler")
        .get()
        .then((querySnapshot) {
      setState(() {
        _projectsList = querySnapshot.docs.map((doc) => doc.data()).toList();
        _filteredProjects = _projectsList; // İlk başta tüm projeleri göster
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 248, 255),
      appBar: AppBar(
        title: Text(
          "PROJELER",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 1, 8, 52),
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
                builder: (context) => MyBottomNavBar(userData: widget.userData),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [_searchBar(), Expanded(child: _projects())],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProjectPage(userData: widget.userData),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: const Color.fromARGB(255, 4, 4, 2),
        ),
        backgroundColor: Color.fromARGB(131, 130, 170, 202),
      ),
    );
  }

  Widget _projects() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredProjects.length,
      itemBuilder: (context, index) {
        final projectData = _filteredProjects[index];

        return GestureDetector(
          onTap: () {
            print("tıklandı");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailPage(
                    projectName: projectData['proje_ad'],
                    projectText: projectData['proje_text'],
                    prejectUserId: projectData['user_id']),
              ),
            );
          },
          child: Container(
            child: ProjectPostWidget(
                projectPdfUrl: projectData['pdf_url'] != null
                    ? projectData['pdf_url']
                    : null,
                projectName: projectData['proje_ad'],
                projectId:
                    projectData['proje_id'], // projectId burada düzeltildi
                userData: widget.userData,
                projectClass: projectData['proje_class'],
                projectDersAd: projectData['proje_ders_ad'],
                projectText: projectData['proje_text'],
                projectDate: projectData['date'],
                likes: List<String>.from(projectData['like_number'] ?? []),
                projectActive: projectData['onay_durumu'],
                prejectUserId: projectData['user_id']),
          ),
        );
      },
    );
  }

  Widget _searchBar() {
    return Container(
      margin: EdgeInsets.only(top: 18, bottom: 3.0),
      padding: EdgeInsets.symmetric(horizontal: 22.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => getMatch(value),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 14, 50, 165), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 14, 50, 165), width: 1.0),
          ),
          contentPadding: EdgeInsets.all(2),
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => clearSearch(),
          ),
          hintText: 'Ders Ara',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
