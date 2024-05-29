import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;

  // Step 2: Add the Constructor
  ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    // Step 3: Determine the image URL
    final String imageUrl = article['urlToImage'] != null
        ? article['urlToImage']
        : 'https://example.com/default-image.png';

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        // Step 3: Use the image URL in DecorationImage
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          // Your other widget components
          Text(
            article['title'] ?? 'No Title',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
