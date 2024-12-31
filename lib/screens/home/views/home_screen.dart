import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/screen_export.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/most_popular.dart';
import 'components/offer_carousel_and_categories.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

@override
  State<HomeScreen> createState() =>
      _HomeState();
}

class _HomeState extends State<HomeScreen> {
  Map<String, List<Book>> _homeBookMap = {
    'Pixar': []
  };
  bool isCompleteFetching = false;  //wait to get books details before showing UI

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
    final _metadata = await DatabaseHelper.instance.rawQuery('SELECT home_categories FROM metadata', []);
    if (_metadata.isNotEmpty){
      var home_categories = jsonDecode(_metadata[0]['home_categories']);
      for (String cat in home_categories){
        var books = await DatabaseHelper.instance.queryByCat(cat);
        if (books.isNotEmpty){
          List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book(slug: book['slug'],
              title: book['title'], cat: book['cat'], image: book['image']));
          }
          homeBookMap[cat] = basicBooks;
        }
      }
      setState(() {
        _homeBookMap: homeBookMap;
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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            //1. Special offers & categories (sliding)
            const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
            //2. List of best sellers
            const SliverToBoxAdapter(child: PopularProducts()),
            //3. Disney
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(child: FlashSale(books: _homeBookMap['Pixar'])),
            ),
            //4. Marvel
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // While loading use 👇
                  // const BannerMSkelton(),‚
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "SPECIAL OFFER",
                    discountParcent: 50,
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  // We have 4 banner styles, all in the pro version
                ],
              ),
            ),
            //5. Pixar
            const SliverToBoxAdapter(child: BestSellers()),
            //6. Star wars
            const SliverToBoxAdapter(child: MostPopular()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),

                  const SizedBox(height: defaultPadding / 4),
                  // While loading use 👇
                  // const BannerSSkelton(),
                  BannerSStyle5(
                    title: "Black \nfriday",
                    subtitle: "50% Off",
                    bottomText: "Collection".toUpperCase(),
                    press: () {
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            //National Geographic
            const SliverToBoxAdapter(child: BestSellers()),
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
