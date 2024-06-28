import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neu_social/screens/job_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class JobPost extends StatefulWidget {
  final String jobName;
  final String jobText;
  final String jobId;
  final String jobMail;
  final String jobTelNo;
  final Map<String, dynamic> userData;
  final Timestamp jobBaslangicTarihi;
  final Timestamp jobBitisTarihi;
  final Timestamp jobDate;

  const JobPost({
    Key? key,
    required this.jobName,
    required this.jobText,
    required this.jobId,
    required this.userData,
    required this.jobMail,
    required this.jobTelNo,
    required this.jobBaslangicTarihi,
    required this.jobBitisTarihi,
    required this.jobDate,
  }) : super(key: key);

  @override
  State<JobPost> createState() => _JobPostState();
}

class _JobPostState extends State<JobPost> {
  bool isSaved = false;

  void _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => jobDetailPage(
                jobName: widget.jobName,
                jobText: widget.jobText,
                jobMail: widget.jobMail,
                jobTelNo: widget.jobTelNo,
                jobDate: widget.jobDate,
                jobBdate: widget.jobBaslangicTarihi,
                jobEdate: widget.jobBitisTarihi),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.only(top: 25, left: 25, right: 25),
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İş ilanı adı
                Text(
                  widget.jobName,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 10),
                // İş ilanı metni
                Text(
                  widget.jobText,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                // İletişim bilgileri
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 199, 217, 244),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: () {
                            _launchCaller(widget.jobTelNo);
                          },
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.jobTelNo,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              widget.jobMail,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
