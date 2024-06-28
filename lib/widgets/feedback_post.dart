import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPost extends StatefulWidget {
  final String text;
  final Timestamp time;
  final String anket_url;
  const FeedbackPost(
      {Key? key,
      required this.text,
      required this.time,
      required this.anket_url})
      : super(key: key);

  @override
  State<FeedbackPost> createState() => _FeedbackPostState();
}

class _FeedbackPostState extends State<FeedbackPost> {
  void _redirectToSurvey() {
    // Anket URL'sine yönlendirme yapılacak
    String surveyUrl = widget.anket_url;
    if (surveyUrl.isNotEmpty) {
      launch(surveyUrl);
    } else {
      // Eğer anket URL'si boşsa, kullanıcıya uyarı verilebilir
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Uyarı !',
            style: TextStyle(
              color: const Color.fromARGB(255, 18, 16, 16),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
          content: Text(
            'Anket Bulunamadı.',
            style: TextStyle(
              color: Color.fromARGB(255, 24, 24, 24),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 15.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: Color.fromARGB(237, 1, 50, 39),
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(widget.time.toDate());

    return GestureDetector(
      onTap: _redirectToSurvey,
      child: Container(
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
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ANKET ',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 18, 16, 16),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
                Text(
                  'Tarih: $formattedDate',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 18, 16, 16),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 30, 28, 28),
                  ),
                  padding: EdgeInsets.all(12),
                  child: const Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
