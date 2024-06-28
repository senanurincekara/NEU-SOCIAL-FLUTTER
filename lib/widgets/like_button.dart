import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isLiked;
  final void Function() onTap;

  const LikeButton({
    Key? key,
    required this.userData,
    required this.isLiked,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
    );
  }
}
