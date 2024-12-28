import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/models/metadata_model.dart';
import 'package:shop/route/screen_export.dart';

import '../../onboarding/views/components/onboarding_content.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  //1. load metadata of project
    void fetchMetadata(http.Client client) async {
      final response = await client.get(Uri.parse(DISNEY_METADATA_URL));
      if (response.statusCode != 200){
        print('Cannot query metadata');
        //todo display something or check if we had metadata in sqlite
      } else {
        //Query db & compare with latest data from cloud
        final metadataInDB = await DatabaseHelper.instance.rawQuery('SELECT * FROM metadata', []);
        if (metadataInDB.isEmpty){
          //insert new
          final metadataObj = MetaDataModel.fromJson(jsonDecode(response.body));
          DatabaseHelper.instance.insertMetadata(metadataObj).then((id){
            print('Inserted metadata');
          });
        } else {
          print("Metadata existed: " + metadataInDB[0]['uuid']);
        }
      }
    }
  //query all books
  Future<List<Book>> fetchBooks(http.Client client) async {
    final response = await client
      .get(Uri.parse('https://api.npoint.io/a458b7fbac62c39b2acd'));
    if (response.statusCode != 200){
      print('cannot query data');
      return [];
    } else {
      // Use the compute function to run in a separate isolate.
      return parseBooks(response.body);
    }
  }

  // A function that converts a response body into a List<Photo>.
  List<Book> parseBooks(String responseBody){
    final parsed =
        (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
    List<Book> list = parsed.map<Book>((json) => Book.fromJson(json)).toList();
    print('Finish loading data: ' + list.length.toString());
    //
    // List<Book> itemsToAdd = [
    //   Book(
    //     slug: 'aaa-bbb-ccc', 
    //     title: 'Title 123456789', 
    //     cat: 'cat 1', 
    //     image: 'Image 222',
    //     isbn: '1111',
    //   amazon: '222',
    //   author: '333',
    //   format: '444',
    //   others: "",
    //   page_num: 34,
    //   age_range: '555',
    //   description: '666',
    //   illustration: '777',
    //   release_time: 122345
    // )];

    // for (Book book in list) {
    //   DatabaseHelper.instance.upsert(book);
    // }

    return list;
  }

  Future<void> _fetchSampleBooks() async {
    final bookMap = await DatabaseHelper.instance.queryBySlug('aaa-bbb-ccc');
    //print(bookMap[0]['title']); //Meet the Firebuds
    //move to home page
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }
  late Future<List<Book>> futureBooks;

  late PageController _pageController;
  int MAX_WAIT_LOADING = 10;   //max 5 seconds

  int _pageIndex = 0;
  final List<Onboard> _onboardData = [
    Onboard(
      image: "assets/Illustration/Illustration-0.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_0.png",
      title: "",  //getting from onboarding_content
      description: ""
    )
  ];

  @override
  void initState() {
      _pageController = PageController(initialPage: 0);
      super.initState();
      fetchMetadata(http.Client());
      // print('begin querying data 111');
      // futureBooks = fetchBooks(http.Client());
      _fetchSampleBooks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardData.length,
                  itemBuilder: (context, index) => OnboardingContent(
                    title: _onboardData[index].title,
                    description: _onboardData[index].description,
                    image: (Theme.of(context).brightness == Brightness.dark &&
                            _onboardData[index].imageDarkTheme != null)
                        ? _onboardData[index].imageDarkTheme!
                        : _onboardData[index].image,
                    isTextOnTop: index.isOdd,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Onboard {
  final String image, title, description;
  final String? imageDarkTheme;

  Onboard({
    required this.image,
    required this.title,
    this.description = "",
    this.imageDarkTheme,
  });
}
