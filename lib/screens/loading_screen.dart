import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/Rimg_api_network.dart';
import '../services/quote_api_network.dart';
import 'Home_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  RandomQuotes quotes = RandomQuotes();
  RandomImg img = RandomImg();
  String data = "";

  Future<Map<String, dynamic>> getQuotes() async {
    Map<String, dynamic> data = await quotes.fetchRandomQuote();
    return data;
  }

  Future<String> getRandomImage({required String tag}) async {
    Map<String, dynamic> images = await img.fetchRandomImages(tag);
    return images['url'];
  }

  Future<void> getData({
    required String author,
    required String content,
    required String tag,
    required String url,
  }) async {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(
            author: author,
            content: content,
            taq: tag,
            url: url,
          );
        },
      ));
    }
  }

  @override
  void initState() {
    getQuotes().then((quoteMap) {
      getRandomImage(tag: quoteMap['tags'][0]).then((url) {
        getData(
            author: quoteMap['author'],
            content: quoteMap['content'],
            url: url,
            tag: quoteMap['tags'][0]);
      });
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
