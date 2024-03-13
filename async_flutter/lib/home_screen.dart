import 'dart:convert';

import 'package:async_flutter/infor_screen.dart';
import 'package:async_flutter/post_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Post'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder(
        future: getArticle(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              final List<Article> data = snapshot.data ?? [];
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final article = data[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
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
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        title: Text(
                          article.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Infor(
                                    title: article.title,
                                    imageUrl: article.urlToImage ?? '',
                                    content: article.content ?? "",
                                  )));
                        },
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<List<Article>> getArticle() async {
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
}
