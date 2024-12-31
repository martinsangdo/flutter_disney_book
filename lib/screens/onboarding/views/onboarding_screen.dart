import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/models/metadata_model.dart';
import 'package:shop/route/screen_export.dart';
import 'package:sqflite/sqflite.dart';

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
        debugPrint('Cannot get metadata from cloud');
        //display something or check if we had metadata in sqlite
        refreshMetaDataWithCloudData(MetaDataModel.empty(uuid: ""));
      } else {
        final metadataObjFromCloud = MetaDataModel.fromJson(jsonDecode(response.body));
        //Query db & compare with latest data from cloud
        refreshMetaDataWithCloudData(metadataObjFromCloud);
      }
    }
    //
  void refreshMetaDataWithCloudData(MetaDataModel metadataObjFromCloud) async{
    //check if table metadata existed
      final metadataInDB = await DatabaseHelper.instance.rawQuery('SELECT * FROM metadata', []);
        if (metadataInDB.isEmpty){
          //there is no metadata in db
          if (metadataObjFromCloud.uuid != ""){
            //insert new
            DatabaseHelper.instance.insertMetadata(metadataObjFromCloud).then((id){
              debugPrint('Inserted metadata into db');
              //get and update new books
              fetchBooks(metadataObjFromCloud.books);
            });
          } else {
            //todo: no data from db neither cloud -> should tell them to close app & try again

          }
        } else if (metadataObjFromCloud.uuid != ""){
          debugPrint('Metadata existed in db: ' + metadataInDB[0]['update_time'].toString());
          //compare update_time
          var updateTimeInDB =  metadataInDB[0]['update_time'];
          var updateTimeInCloud =  metadataObjFromCloud.update_time;
          if (updateTimeInDB != updateTimeInCloud){
            //update metadata in db
            DatabaseHelper.instance.updateMetadata(metadataObjFromCloud).then((id){
              debugPrint('Updated new metadata into db');
              //get and update new books
              fetchBooks(metadataObjFromCloud.books);
            });
          } else {
            //do nothing because there is no new info from cloud
            move2HomePage();
          }
        } else {
          //do nothing because metadata existed in db & has nothing from cloud
          move2HomePage();
        }
  }
  //query all books
  void fetchBooks(String bookUrl) async {
    final response = await http.Client().get(Uri.parse(bookUrl));
    if (response.statusCode != 200){
      debugPrint('Cannot get books from cloud');
      refreshBooksWithCloudData([]);
    } else {
      final parsed =
        (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      List<Book> list = parsed.map<Book>((json) => Book.fromJson(json)).toList();
      refreshBooksWithCloudData(list);
    }
  }
  //update book data
  void refreshBooksWithCloudData(List<Book> bookList) async{
    //check if there is any books in db or not
    List<Map> result = await DatabaseHelper.instance.rawQuery('SELECT COUNT(*) FROM book', []);
    if (result.isEmpty){
      //no data in db
      if (bookList.isEmpty){
        //todo: no data from db neither cloud -> should tell them to close app & try again

      } else {
        updateBookDataAndOpenHome(bookList);
      }
    } else {
      //there is book data in db -> updata all book data
      updateBookDataAndOpenHome(bookList);
    }
  }

  void updateBookDataAndOpenHome(List<Book> bookList){
    for (Book book in bookList) {
      DatabaseHelper.instance.upsert(book);
    }
    //
    move2HomePage();
  }

  void move2HomePage(){
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<void> _fetchSampleBooks() async {
    final bookMap = await DatabaseHelper.instance.queryBySlug('aaa-bbb-ccc');
    //print(bookMap[0]['title']); //Meet the Firebuds
    //move to home page
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
