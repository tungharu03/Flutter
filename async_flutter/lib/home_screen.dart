import 'dart:convert';

import 'package:async_flutter/infor_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Article> _articles = [];
  late List<Article> _filteredArticles = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getArticles();
  }

  void _getArticles() async {
    try {
      final List<Article> articles = await getArticles();
      setState(() {
        _articles = articles;
        _filteredArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterArticles(String keyword) {
    setState(() {
      _filteredArticles = _articles
          .where((article) =>
              article.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateTime.now().day}/${DateTime.now().month}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Explore',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterArticles,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _filterCategory('All'),
                  child: Text('All'),
                ),
                ElevatedButton(
                  onPressed: () => _filterCategory('Politics'),
                  child: Text('Politics'),
                ),
                ElevatedButton(
                  onPressed: () => _filterCategory('Sports'),
                  child: Text('Sports'),
                ),
                ElevatedButton(
                  onPressed: () => _filterCategory('Health'),
                  child: Text('Health'),
                ),
                ElevatedButton(
                  onPressed: () => _filterCategory('Crypto'),
                  child: Text('Crypto'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredArticles.isEmpty
                    ? Center(child: Text('No articles found'))
                    : ListView.builder(
                        itemCount: _filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = _filteredArticles[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: article.urlToImage != null
                                      ? Image.network(
                                          article.urlToImage!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          width: 80,
                                          height: 80,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  article.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Infor(
                                        title: article.title,
                                        imageUrl: article.urlToImage ?? '',
                                        content: article.content ?? "",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Person',
          ),
        ],
      ),
    );
  }

  Future<List<Article>> getArticles() async {
    const url =
        'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=643c56736f5c499c9b6368b62c1d2c9c';
    final res = await http.get(Uri.parse(url));
    final body = json.decode(res.body) as Map<String, dynamic>;

    final List<Article> result = [];

    for (final article in body['articles']) {
      result.add(
        Article(
          title: article['title'],
          content: article['content'],
          urlToImage: article['urlToImage'],
        ),
      );
    }
    return result;
  }

  void _filterCategory(String category) {
    setState(() {
      _filteredArticles = _articles
          .where((article) => article.title.toLowerCase().contains(category.toLowerCase()))
          .toList();
    });
  }
}

class Article {
  final String title;
  final String? content;
  final String? urlToImage;

  Article({required this.title, this.content, this.urlToImage});
}

