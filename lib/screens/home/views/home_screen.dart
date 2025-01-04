import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/constants.dart';
import 'package:shop/globals.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/home/views/components/horizontal_list.dart';

import 'components/offer_carousel_and_categories.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

@override
  State<HomeScreen> createState() =>
      _HomeState();
}

class _HomeState extends State<HomeScreen> {
  List<Book> _bestSellers = [];
  Map<String, List<Book>> _homeBookMap = {};  //key: category, values: list of items
  bool _isCompleteFetching = false;  //wait to get books details before showing UI
  String newArrivalImageUrl = ''; //random url
  String editorChoiceImageUrl = ''; //random url

  //setup Bottom Bar
  int _selectedBottomIndex = 0;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
    if (context.mounted){
      if (index == 1){
        Navigator.pushNamed(context, discoverScreenRoute);  //Catetories pages
      } else if (index == 2){
        Navigator.pushNamed(context, searchScreenRoute);  //Search page
      }
    }
  }

  int getRandomNumberInRange(int max) {
    final random = Random();
    return random.nextInt(max); // not Include max in the range
  }
  //query by transactions to speed up the time
  Future<void> _getLatestBooksBatch() async {
    Map<String, List<Book>> homeBookMap = {};
    final _metadata = await DatabaseHelper.instance.rawQuery('SELECT home_categories,best_sellers,affiliate_post_fix FROM metadata', []);
    DateTime now = DateTime.now();
        int timestamp = now.millisecondsSinceEpoch;
        debugPrint('after metadata ' + timestamp.toString());
    if (_metadata.isNotEmpty){
      //save post fix
      global_affiliate_post_fix = _metadata[0]['affiliate_post_fix'];
      //find best seller books
      List<Book> _bestSellersDb = [];
      List<dynamic> best_sellers_slugs = jsonDecode(_metadata[0]['best_sellers']);
      final books = await DatabaseHelper.instance.queryBookIn(best_sellers_slugs);
      if (books.isNotEmpty){
        for (Map book in books){
          _bestSellersDb.add(Book.convert(book));
        }
      }
      //find latest books on each categories
      var home_categories = jsonDecode(_metadata[0]['home_categories']);
      //
      for (String cat in home_categories){
        var books = await DatabaseHelper.instance.queryByCat(cat);
        if (books.isNotEmpty){
          List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book.convert(book));
          }
          homeBookMap[cat] = basicBooks;
        }
      }
      setState(() {
        _bestSellers = _bestSellersDb;
        _homeBookMap = homeBookMap;
        _isCompleteFetching = true;
        //get random book to show in banners
        String randCat = home_categories[getRandomNumberInRange(home_categories.length)];
        newArrivalImageUrl = homeBookMap[randCat]![getRandomNumberInRange(homeBookMap[randCat]!.length)].image;
        editorChoiceImageUrl = homeBookMap[randCat]![getRandomNumberInRange(homeBookMap[randCat]!.length)].image;
        DateTime now = DateTime.now();
        int timestamp = now.millisecondsSinceEpoch;
        debugPrint('finish ' + timestamp.toString());
      });
    } else {
      //empty meta data
      setState(() {
        _isCompleteFetching = true;
      });
    }
  }

  Future<void> _getLatestBooks() async {

  }
  //
  @override
  void initState() {
      super.initState();
      DateTime now = DateTime.now();
      int timestamp = now.millisecondsSinceEpoch;
      debugPrint('begin ' + timestamp.toString());
      // _getLatestBooks();
      _getLatestBooksBatch();
  }
  @override
  void dispose() {
    super.dispose();
  }
  //
  @override
  Widget build(BuildContext context) {
    if (!_isCompleteFetching){
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            //1. Special offers & categories (sliding)
            const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
            //2. List of best sellers
            SliverToBoxAdapter(child: HorizontalList(header: 'Best sellers', books: _bestSellers, isShowAll: false)),
            //3. Latest books
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    BannerSStyle1(
                      title: "New \narrival",
                      subtitle: "SPECIAL OFFER",
                      image: DISNEY_IMG_URI + newArrivalImageUrl,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookmarkScreen(appBarTitle: 'New arrival', pageType: 'new_arrival')
                          ));
                      },
                    )
                  ],
                ),
              )
            ),
            //4. Disney
            SliverToBoxAdapter(child: HorizontalList(header: 'Disney', books: _homeBookMap['Disney']!, isShowAll: true)),
            //5. Marvel
            SliverToBoxAdapter(child: HorizontalList(header: 'Marvel', books: _homeBookMap['Marvel']!, isShowAll: true)),
            //5. Pixar
            SliverToBoxAdapter(child: HorizontalList(header: 'Pixar', books: _homeBookMap['Pixar']!, isShowAll: true)),
            //6. Star wars
            SliverToBoxAdapter(child: HorizontalList(header: 'Star Wars', books: _homeBookMap['Star Wars']!, isShowAll: true)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  const SizedBox(height: defaultPadding / 4),
                  BannerSStyle5(
                    title: "Editor's \ncollections",
                    image: DISNEY_IMG_URI + editorChoiceImageUrl,
                    press: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookmarkScreen(appBarTitle: 'Editor Choices', pageType: 'editor_choice')
                          ));
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            //National Geographic
            SliverToBoxAdapter(child: HorizontalList(header: 'National Geographic', books: _homeBookMap['National Geographic']!, isShowAll: true)),
            //
            SliverToBoxAdapter(child: HorizontalList(header: 'Young Adult', books: _homeBookMap['Young Adult']!, isShowAll: true)),
          ],
        ),
      ),  //end body
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedBottomIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ) //end Bottom Bar
    );
  }
}
