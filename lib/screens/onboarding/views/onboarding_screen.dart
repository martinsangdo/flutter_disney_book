import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/screen_export.dart';

import '../../onboarding/views/components/onboarding_content.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  //query data
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
    //   Book(slug: 'aa11', title: 'Title 1', cat: 'cat 1', image: 'Image 222'),
    // ];

    // for (Book book in list) {
    //   DatabaseHelper.instance.insert(book);
    // }
    // print(list[0].others);

    _fetchBooks();
    
    return list;
  }

  Future<void> _fetchBooks() async {
    final bookMap = await DatabaseHelper.instance.queryBySlug('firebuds-meet-the-firebuds');
    // print(bookMap[0]['others']);
    var others = jsonDecode(bookMap[0]['others']);
    print(others[1]['slugs'][0]);
    //move to home page
    if (context.mounted) {
      Navigator.pushNamed(context, homeScreenRoute);
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
      print('begin querying data 111');
      futureBooks = fetchBooks(http.Client());
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
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton(
              //     onPressed: () {
              //       Navigator.pushNamed(context, logInScreenRoute);
              //     },
              //     child: Text(
              //       "Skip",
              //       style: TextStyle(
              //           color: Theme.of(context).textTheme.bodyLarge!.color),
              //     ),
              //   ),
              // ),
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
