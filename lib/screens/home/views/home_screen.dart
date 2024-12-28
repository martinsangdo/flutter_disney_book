import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/constants.dart';
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
  //
  @override
  void initState() {
      super.initState();
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
            //3. 
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(child: FlashSale()),
            ),
            //4. New arrival
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
            //5. Best sellers
            const SliverToBoxAdapter(child: BestSellers()),
            //
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
