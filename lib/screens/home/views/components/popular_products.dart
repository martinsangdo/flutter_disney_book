// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_field, non_constant_identifier_names, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({
    super.key,
  });
   @override
  State<PopularProducts> createState() => _PopularState();
}

class _PopularState extends State<PopularProducts> {
  List<Book> _popularBooks = [];

  @override
  void initState() {
      super.initState();
      _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    final _metadata = await DatabaseHelper.instance.rawQuery('SELECT best_sellers FROM metadata', []);
    if (_metadata.isNotEmpty){
      List<dynamic> best_sellers_slugs = jsonDecode(_metadata[0]['best_sellers']);
      // query book details
      final books = await DatabaseHelper.instance.queryBookIn(best_sellers_slugs);
      if (books.isNotEmpty){
        List<Book> _popularBooksDb = [];
        for (Map book in books){
          _popularBooksDb.add(Book(slug: book['slug'],
              title: book['title'], cat: book['cat'], image: book['image'], 
              release_time: book['release_time'] ));
        }
        setState(() {
          _popularBooks = _popularBooksDb;
        });
      }
    } else {

    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Best sellers books",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // const ProductsSkelton(),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularBooks.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == _popularBooks.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: ProductCard(
                image: DISNEY_IMG_URI + _popularBooks[index].image,
                brandName: _popularBooks[index].cat,
                title: _popularBooks[index].title,
                press: () {
                  Navigator.pushNamed(context, productDetailsScreenRoute,
                      arguments: index.isEven);
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
