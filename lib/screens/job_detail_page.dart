import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class jobDetailPage extends StatelessWidget {
  final String jobName;
  final String jobText;
  final String jobMail;
  final String jobTelNo;
  final Timestamp jobDate;
  final Timestamp jobBdate;
  final Timestamp jobEdate;

  const jobDetailPage({
    Key? key,
    required this.jobName,
    required this.jobText,
    required this.jobMail,
    required this.jobTelNo,
    required this.jobDate,
    required this.jobBdate,
    required this.jobEdate,
  }) : super(key: key);
  void _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

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
              "Bizimle Çalışmak İster misiniz ?",
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
            _Inputs(context),
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
        'assets/images/job.png', // Resmin dosya yolunu belirt
        fit: BoxFit.cover, // Resmi container'a sığdır
      ),
    );
  }

  Widget _Inputs(BuildContext context) {
    DateTime startDate = jobBdate.toDate();
    DateTime endDate = jobEdate.toDate();

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
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    jobText,
                    style:
                        TextStyle(fontSize: 16, fontFamily: 'Times New Roman'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Başlangıç Tarihi:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${startDate.day}/${startDate.month}/${startDate.year}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bitiş Tarihi:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${endDate.day}/${endDate.month}/${endDate.year}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    ' İletişim İçin ',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.mail),
                        onPressed: () {
                          _launchEmail(jobMail);
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          _launchEmail(jobMail);
                        },
                        child: Text(
                          jobMail,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.phone),
                        onPressed: () {
                          _launchCaller(jobTelNo);
                        },
                      ),
                      // SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _launchCaller(jobTelNo);
                        },
                        child: Text(
                          jobTelNo,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
