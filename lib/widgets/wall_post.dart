import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:neu_social/screens/topics_detail_page.dart';
import 'package:neu_social/widgets/like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final Timestamp time;
  final String postId;
  final List<String> likes;
  final Map<String, dynamic> userData;
  final int commentCount;

  const WallPost({
    Key? key,
    required this.message,
    required this.user,
    required this.time,
    required this.userData,
    required this.postId,
    required this.likes,
    required this.commentCount,
  }) : super(key: key);

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
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
        FirebaseFirestore.instance.collection('topics').doc(widget.postId);

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

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(widget.time.toDate());

    return Container(
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
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5, right: 8, left: 8),
            child: Text(
              'Tarih: $formattedDate',
              style: TextStyle(
                color: const Color.fromARGB(255, 18, 16, 16),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 30, 28, 28),
                ),
                padding: EdgeInsets.all(10),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      maxLines: 2, // İçeriği iki satıra sınırlıyoruz
                      overflow: TextOverflow.ellipsis, // Taşan kısmı ... ile
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopicDetailPage(
                              topicId: widget.postId,
                              userData: widget.userData),
                        ),
                      );
                    },
                  ),
                  Text(
                    widget.commentCount.toString(),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 18, 16, 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LikeButton(
                userData: widget.userData,
                isLiked: isLiked,
                onTap: toggleLike,
              ),
              const SizedBox(width: 8),
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
    );
  }
}
