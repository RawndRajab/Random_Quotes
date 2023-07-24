import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/Rimg_api_network.dart';
import '../services/quote_api_network.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  final String content;
  final String author;
  final String taq;
  final String url;
  const HomePage(
      {Key? key,
      required this.content,
      required this.author,
      required this.taq,
      required this.url})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RandomQuotes quotes = RandomQuotes();
  RandomImg img = RandomImg();

  String content = "";
  String author = "";
  String taq = "";
  String url = "";
  bool isLoaded = false;
  ImageProvider assetsImage = AssetImage('assets/images.jfif');
  GlobalKey globalKey = GlobalKey();
  Uint8List? pngBytes;

  Future<void> getQuotes() async {
    Map<String, dynamic> data = await quotes.fetchRandomQuote();
    setState(() {
      content = data['content'];
      author = data['author'];
      taq = data['tags'][0];
    });
  }

  Future<void> getRandomImage() async {
    Map<String, dynamic> images = await img.fetchRandomImages(taq);
    setState(() {
      url = images['url'];
    });
  }

  void update() {
    getImage();
    setState(() {
      getQuotes();
      getRandomImage();
    });
  }

  void getImage() {
    NetworkImage(url)
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      setState(() {
        isLoaded = true;
      });
    }));
  }

  @override
  void initState() {
    content = widget.content;
    author = widget.author;
    taq = widget.taq;
    url = widget.url;
    getImage();
    // TODO: implement initState
    super.initState();
  }

  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // if (boundary.debugNeedsPaint) {
    if (kDebugMode) {
      print("Waiting for boundary to be painted.");
    }
    await Future.delayed(const Duration(milliseconds: 20));
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    pngBytes = byteData!.buffer.asUint8List();
    if (kDebugMode) {
      print(pngBytes);
    }
    if (mounted) {
      _onShareXFileFromAssets(context, byteData);
    }
    // }
  }

  void _onShareXFileFromAssets(BuildContext context, ByteData? data) async {
    final box = context.findRenderObject() as RenderBox?;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // final data = await rootBundle.load('assets/flutter_logo.png');
    final buffer = data!.buffer;
    final shareResult = await Share.shareXFiles(
      [
        XFile.fromData(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          name: 'screen_shot.png',
          mimeType: 'image/png',
        ),
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
  }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const SizedBox(
          width: 1,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {
                update();
              },
              icon: const Icon(
                Icons.refresh_outlined,
                color: Colors.green,
                size: 45,
              ),
            ),
          )
        ],
      ),
      body: RepaintBoundary(
        key: globalKey,
        child: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: !isLoaded ? assetsImage : NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 200),
                      child: SvgPicture.asset(
                        "assets/img.svg",
                        width: 120,
                        height: 120,
                      ),
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            content,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            padding: const EdgeInsets.all(30),
                            child: Text(
                              author,
                              style: TextStyle(
                                backgroundColor: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                                color: Colors.green[200],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _capturePng,
        label: const Text('Take screenshot'),
        icon: const Icon(Icons.share_rounded),
        backgroundColor: Colors.green,
      ),
    );
  }
}
/*

 */
