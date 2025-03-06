import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String name;
  final String timeAgo;
  final String postHeader;
  final String postBody;
  final String? imageUrl;

  const PostCard({
    Key? key,
    required this.name,
    required this.timeAgo,
    required this.postHeader,
    required this.postBody,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(postHeader),
            SizedBox(height: 8),
            Text(postBody),
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              SizedBox(height: 10),
              Image.network(imageUrl!, height: 150, fit: BoxFit.cover),
            ],
          ],
        ),
      ),
    );
  }
}
