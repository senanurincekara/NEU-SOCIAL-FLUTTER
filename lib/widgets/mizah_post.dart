import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MizahPost extends StatefulWidget {
  final String message;
  final String postId;
  final List<String> likes;
  final Map<String, dynamic> userData;
  final String imageUrl; // Keep it as a String
  final Timestamp date;

  const MizahPost({
    Key? key,
    required this.message,
    required this.postId,
    required this.likes,
    required this.userData,
    required this.imageUrl,
    required this.date,
  }) : super(key: key);

  @override
  State<MizahPost> createState() => _MizahPostState();
}

class _MizahPostState extends State<MizahPost> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLiked = widget.likes.contains(widget.userData['email']);
    });
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('mizah').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'post_likes': FieldValue.arrayUnion([widget.userData['email']])
      });
    } else {
      postRef.update({
        'post_likes': FieldValue.arrayRemove([widget.userData['email']])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime postDate = widget.date.toDate();
    String formattedDate = DateFormat('dd/MM/yyyy').format(postDate);

    return Container(
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
          // Mizah gönderisi metni
          Text(
            widget.message,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          // Gönderiye ait görsel
          if (widget.imageUrl.isNotEmpty)
            Image.network(
              widget.imageUrl,
              height: 200, // İstenilen yüksekliğe ayarlayabilirsiniz
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 10),
          // Gönderi sahibinin adı ve soyadı
          Text(
            'Gönderen: ${widget.userData["name"]} ${widget.userData["surname"]}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Gönderi tarihi
          Text(
            'Tarih: $formattedDate',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 10),
          // Beğeni butonu ve beğeni sayısı
          Row(
            children: [
              IconButton(
                onPressed: toggleLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    ' beğeni',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
