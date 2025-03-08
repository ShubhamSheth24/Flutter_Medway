import 'package:flutter/material.dart';

class Article {
  final String title;
  final String date;
  final String readTime;
  final String content;
  final String imagePath; // Added for unique images

  Article({
    required this.title,
    required this.date,
    required this.readTime,
    required this.content,
    required this.imagePath, // New required field
  });
}

List<Article> articles = [
  Article(
    title: 'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
    date: 'Jun 10, 2023',
    readTime: '5 min read',
    content:
        'Fruits are nature\'s wonderful gift to mankind; they are an absolute feast to our sight and provide numerous health benefits. This article explores 25 of the healthiest fruits recommended by nutritionists, including apples, bananas, berries, and more...',
    imagePath: 'assets/article1.jpg', // Unique image
  ),
  Article(
    title: 'The Impact of COVID-19 on Healthcare Systems',
    date: 'Jul 10, 2023',
    readTime: '5 min read',
    content:
        'The COVID-19 pandemic has dramatically altered healthcare systems worldwide. This article discusses the challenges faced, adaptations made, and long-term impacts on medical infrastructure and patient care...',
    imagePath: 'assets/article2.jpg',
  ),
  Article(
    title: 'Understanding Mental Health: Breaking the Stigma',
    date: 'Aug 15, 2023',
    readTime: '6 min read',
    content:
        'Mental health is as important as physical health, yet it remains shrouded in stigma. This article delves into common mental health conditions, their symptoms, and ways to seek help while breaking down societal barriers...',
    imagePath: 'assets/article3.jpg',
  ),
  Article(
    title: 'The Benefits of Regular Exercise on Heart Health',
    date: 'Sep 5, 2023',
    readTime: '4 min read',
    content:
        'Exercise is a cornerstone of a healthy lifestyle, especially for your heart. Learn how regular physical activity can reduce the risk of cardiovascular diseases, improve circulation, and boost overall well-being...',
    imagePath: 'assets/article4.jpg',
  ),
  Article(
    title: 'Nutrition Tips for Managing Diabetes',
    date: 'Oct 20, 2023',
    readTime: '5 min read',
    content:
        'Managing diabetes effectively requires a balanced diet. This article provides practical nutrition tips, including the best foods to stabilize blood sugar, portion control strategies, and meal planning advice...',
    imagePath: 'assets/article5.jpg',
  ),
  Article(
    title: 'Sleep and Its Impact on Your Immune System',
    date: 'Nov 12, 2023',
    readTime: '5 min read',
    content:
        'Quality sleep is crucial for a strong immune system. Discover how sleep affects your body\'s ability to fight infections, the science behind sleep cycles, and tips for improving your sleep hygiene...',
    imagePath: 'assets/article6.jpg',
  ),
  Article(
    title: 'The Rise of Telemedicine: Healthcare in the Digital Age',
    date: 'Dec 1, 2023',
    readTime: '6 min read',
    content:
        'Telemedicine has transformed how we access healthcare. This article explores its growth, benefits like convenience and accessibility, and challenges such as technology barriers and privacy concerns...',
    imagePath: 'assets/article7.jpg',
  ),
];

class HealthArticleCard extends StatelessWidget {
  final String title;
  final String readTime;
  final String date;
  final String imagePath; // Added for unique images

  const HealthArticleCard({
    super.key,
    required this.title,
    required this.readTime,
    required this.date,
    required this.imagePath, // New required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagePath), // Use unique image
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$date • $readTime',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${article.date} • ${article.readTime}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(article.imagePath), // Use unique image here too
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                article.content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllArticlesPage extends StatelessWidget {
  const AllArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Health Articles'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(article: article),
                  ),
                );
              },
              child: HealthArticleCard(
                title: article.title,
                date: article.date,
                readTime: article.readTime,
                imagePath: article.imagePath, // Pass unique image
              ),
            );
          },
        ),
      ),
    );
  }
}