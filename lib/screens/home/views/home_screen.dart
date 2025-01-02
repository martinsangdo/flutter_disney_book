import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/constants.dart';
import 'package:shop/globals.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/home/views/components/horizontal_list.dart';

import 'components/best_sellers.dart';
import 'components/most_popular.dart';
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

  //setup Bottom Bar
  int _selectedBottomIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  Future<void> _getLatestBooks() async {
    Map<String, List<Book>> homeBookMap = {};
    final _metadata = await DatabaseHelper.instance.rawQuery('SELECT home_categories,best_sellers,affiliate_post_fix FROM metadata', []);
    if (_metadata.isNotEmpty){
      //save post fix
      global_affiliate_post_fix = _metadata[0]['affiliate_post_fix'];
      //find best seller books
      List<Book> _bestSellersDb = [];
      List<dynamic> best_sellers_slugs = jsonDecode(_metadata[0]['best_sellers']);
      final books = await DatabaseHelper.instance.queryBookIn(best_sellers_slugs);
      if (books.isNotEmpty){
        for (Map book in books){
          _bestSellersDb.add(Book(slug: book['slug'],
              title: book['title'], cat: book['cat'], 
              image: book['image'], description: book['description'],
              amazon: book['amazon']));
        }
      }
      //find latest books on each categories
      var home_categories = jsonDecode(_metadata[0]['home_categories']);
      for (String cat in home_categories){
        var books = await DatabaseHelper.instance.queryByCat(cat);
        if (books.isNotEmpty){
          List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book(slug: book['slug'],
              title: book['title'], cat: book['cat'], 
              image: book['image'], description: book['description'],
              amazon: book['amazon']));
          }
          homeBookMap[cat] = basicBooks;
        }
      }
      setState(() {
        _bestSellers = _bestSellersDb;
        _homeBookMap = homeBookMap;
        _isCompleteFetching = true;
      });
    } else {

    }
  }
  //
  @override
  void initState() {
      super.initState();
      _getLatestBooks();
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
            //3. Disney
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(child: HorizontalList(header: 'Disney', books: _homeBookMap['Disney']!, isShowAll: true)),
            ),
            //4. Marvel
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    press: () {
                      Navigator.pushNamed(context, bookmarkScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  // We have 4 banner styles, all in the pro version
                ],
              ),
            ),
            //
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
                  // While loading use 👇
                  // const BannerSSkelton(),
                  BannerSStyle5(
                    title: "Editor's \ncollections",
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
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
//bottom bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedBottomIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ) //end Bottom Bar
    );
  }
}
