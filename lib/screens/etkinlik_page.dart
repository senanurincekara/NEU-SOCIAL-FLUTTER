import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:neu_social/widgets/EventData.dart';
import 'package:url_launcher/url_launcher.dart';

class EtkinlikPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EtkinlikPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<EtkinlikPage> createState() => _EtkinlikPageState();
}

class _EtkinlikPageState extends State<EtkinlikPage> {
  void _goToTheUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Genel tarayıcıya yönlendirme
      await launch(url, forceSafariVC: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventData>>(
      future: _fetchEventsFromJson(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No events available'));
        } else {
          return Scaffold(
            backgroundColor: Color.fromARGB(255, 216, 248, 255),
            body: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildEventCard(snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildEventCard(EventData event) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _goToTheUrl(event.urlAddress);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                event.image,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.date,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<EventData>> _fetchEventsFromJson(BuildContext context) async {
    String data =
        await DefaultAssetBundle.of(context).loadString('assets/data.json');
    List<dynamic> jsonData = json.decode(data);
    List<EventData> events = [];
    for (var item in jsonData) {
      events.add(EventData.fromJson(item));
    }
    return events;
  }
}
