import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neu_social/widgets/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ProjectPostWidget extends StatefulWidget {
  final String projectPdfUrl;
  final String projectName;
  final String projectId;
  final String projectClass;
  final String projectDersAd;
  final String projectText;
  final Timestamp projectDate;
  final String projectActive;
  final List<String> likes;
  final Map<String, dynamic> userData;
  final String prejectUserId;

  const ProjectPostWidget(
      {Key? key,
      required this.projectPdfUrl,
      required this.projectName,
      required this.projectId,
      required this.userData,
      required this.projectClass,
      required this.projectDersAd,
      required this.projectText,
      required this.projectDate,
      required this.projectActive,
      required this.likes,
      required this.prejectUserId})
      : super(key: key);

  @override
  State<ProjectPostWidget> createState() => _ProjectPostWidgetState();
}

class _ProjectPostWidgetState extends State<ProjectPostWidget> {
  bool isSaved = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLiked = widget.likes.contains(widget.userData['email']);
    });
  }

  void toggleLike() {
    bool newLikeStatus = !isLiked;
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('projeler').doc(widget.projectId);

    if (newLikeStatus) {
      postRef.update({
        'like_number': FieldValue.arrayUnion([widget.userData['email']])
      }).then((_) {
        setState(() {
          isLiked = newLikeStatus;
        });
      }).catchError((error) {
        print("Error updating like: $error");
      });
    } else {
      postRef.update({
        'like_number': FieldValue.arrayRemove([widget.userData['email']])
      }).then((_) {
        setState(() {
          isLiked = newLikeStatus;
        });
      }).catchError((error) {
        print("Error updating like: $error");
      });
    }
  }

  Future<void> downloadFile(BuildContext context, String url) async {
    final firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.refFromURL(url);

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String fileName =
        url.split('/').last.split('?').first; // Dosya adını al
    final File tempFile = File('$appDocPath/$fileName'); // Dosyayı oluştur

    try {
      await ref.writeToFile(tempFile);
      OpenFile.open(tempFile.path);
    } on firebase_storage.FirebaseException catch (e) {
      print('Download error: $e');
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Error, file cannot be downloaded',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd.MM.yyyy').format(widget.projectDate.toDate());

    return Container(
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color.fromARGB(115, 7, 0, 69)),
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
          Padding(
            padding: EdgeInsets.only(top: 5, right: 8, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.projectDersAd,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 18, 16, 16),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 30, 28, 28),
                    ),
                    padding: EdgeInsets.all(12),
                    child: InkWell(
                      hoverColor: const Color.fromARGB(255, 54, 244, 181),
                      onTap: () {
                        print("tapped on containerr");
                        downloadFile(context, widget.projectPdfUrl);
                      },
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.projectText,
                      maxLines: 4, // İçeriği iki satıra sınırlıyoruz
                      overflow: TextOverflow.ellipsis, // Taşan kısmı ... ile
                      style: TextStyle(
                          fontFamily: "Times New Roman",
                          color: Color.fromARGB(255, 0, 4, 25)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  LikeButton(
                    userData: widget.userData,
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 18, 16, 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Tarih: ' + formattedDate,
                style: TextStyle(
                  color: const Color.fromARGB(255, 18, 16, 16),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
