import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';
//all books in a category
class BookmarkScreen extends StatefulWidget {
  String pageType = 'category'; //or 'bookmark'
  String appBarTitle = '';

  BookmarkScreen({super.key, required this.appBarTitle, required this.pageType});

  @override
  State<BookmarkScreen> createState() => _LocalState();
}

class _LocalState extends State<BookmarkScreen> {
  bool _isCompleteFetching = false;  //wait to get books details before showing UI
  List<Book> showingBooks = [];
  int _currentPage = 0; //start from 0
  int totalPage = 0;
  
  void _fetchLatestBooks() async{
    var books = await DatabaseHelper.instance.queryLatestBooks(_currentPage, PAGE_SIZE * 2);
    if (books.isNotEmpty){
      List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book(slug: book['slug'],
              title: book['title'], cat: book['cat'], 
              image: book['image'], description: book['description'],
              amazon: book['amazon']));
          }
          setState(() {
            showingBooks = basicBooks;
            _isCompleteFetching = true;
            totalPage = 0;
          });
    } else {
        setState(() {
            _isCompleteFetching = true;
            totalPage = 0;
        });
    }
  }

  @override
  void initState() {
      super.initState();
      if (widget.pageType == 'new_arrival'){
          _fetchLatestBooks();
      }
  }
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
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black
        ), 
        title: Text(widget.appBarTitle),
        centerTitle: true
      ),
      body: SafeArea(
        child: CustomScrollView(
        slivers: [
          // While loading use 👇
          //  BookMarksSlelton(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ProductCard(
                    image: DISNEY_IMG_URI + showingBooks[index].image,
                    brandName: showingBooks[index].cat,
                    title: showingBooks[index].title,
                    press: () {
                      Navigator.pushNamed(context, productDetailsScreenRoute);
                    },
                  );
                },
                childCount: showingBooks.length,
              ),
            ),
          ),
        ],
      )),
        bottomNavigationBar: (totalPage > 0) ? Card(
          margin: EdgeInsets.zero,
          child: NumberPaginator(
            // by default, the paginator shows numbers as center content
            numberPages: totalPage,
            onPageChange: (int index) { //start from 0
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ) : null
      
    );
  }
}
