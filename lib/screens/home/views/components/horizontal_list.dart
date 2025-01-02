// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_field, non_constant_identifier_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

class HorizontalList extends StatefulWidget {
  List<Book> books = []; //list of books to show in UI
  String header;  //header of the list
  bool isShowAll = false; //to show See All or not 

  HorizontalList({
    super.key, required this.books, required this.header, required this.isShowAll
  });
   @override
  State<HorizontalList> createState() => _LocalState();
}

class _LocalState extends State<HorizontalList> {
  List<Book> _showingList = [];
  String _showingHeader = '';

  @override
  void initState() {
      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _showingList = widget.books;
    _showingHeader = widget.header;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(
                _showingHeader,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (widget.isShowAll)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(detail: _showingList[0]) //todo to show all books
                        ));
                  },
                  child: const Text(
                    "Show more >>",
                    style: TextStyle(color: Colors.blue)
                  )
                )
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _showingList.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == _showingList.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: ProductCard(
                image: DISNEY_IMG_URI + _showingList[index].image,
                brandName: _showingList[index].cat,
                title: _showingList[index].title,
                press: () {
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(detail: _showingList[index]),
                        ));
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
