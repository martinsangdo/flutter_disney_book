import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/screens/product/views/product_details_screen.dart';

import '../../../constants.dart';
//all books in a category
class BookmarkScreen extends StatefulWidget {
  String pageType = 'category'; //or bookmark, new_arrival, editor_choice
  String appBarTitle = '';  //can be category name

  BookmarkScreen({super.key, required this.appBarTitle, required this.pageType});

  @override
  State<BookmarkScreen> createState() => _LocalState();
}

class _LocalState extends State<BookmarkScreen> {
  bool _isCompleteFetching = false;  //wait to get books details before showing UI
  List<Book> showingBooks = [];
  int _currentPage = 0; //start from 0
  int totalPage = 1;
  //get latest books
  void _fetchLatestBooks() async{
    var books = await DatabaseHelper.instance.queryLatestBooks(_currentPage, DOUBLE_PAGE_SIZE);
    if (books.isNotEmpty){
      List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book.convert(book));
          }
          setState(() {
            showingBooks = basicBooks;
            _isCompleteFetching = true;
            totalPage = 0;
          });
    } else {
        setState(() {
            _isCompleteFetching = true;
        });
    }
  }
  //get books of 1 category
  void _fetchCatBooksByCat() async{
    var books = await DatabaseHelper.instance.queryByCatPagination(widget.appBarTitle, _currentPage, DOUBLE_PAGE_SIZE);
    if (books.isNotEmpty){
      List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book.convert(book));
          }
          setState(() {
            showingBooks = basicBooks;
            _isCompleteFetching = true;
          });
    } else {
        setState(() {
            _isCompleteFetching = true;
        });
    }
  }
  //get total of items
  Future<int> _fetchTotalPages() async{
    int _totalPage = 1;
    var bookTotal = await DatabaseHelper.instance.queryByCatTotal(widget.appBarTitle);
    if (bookTotal.isNotEmpty){
      if (bookTotal[0]['total'] >= DOUBLE_PAGE_SIZE){
        //we have more than 1 page
        _totalPage = (bookTotal[0]['total'] / DOUBLE_PAGE_SIZE).ceil();
      }
    }
    return _totalPage;
  }

//get books of 1 category
  void _fetchCatBooksByEditor() async{
    var books = await DatabaseHelper.instance.queryByFormat('Print, E-Book & Audio', DOUBLE_PAGE_SIZE);
    if (books.isNotEmpty){
      List<Book> basicBooks = [];
          for (Map book in books){
            basicBooks.add(Book.convert(book));
          }
          setState(() {
            showingBooks = basicBooks;
            _isCompleteFetching = true;
          });
    } else {
        setState(() {
            _isCompleteFetching = true;
        });
    }
  }
  //
  void _loadBooks(){
    if (widget.pageType == 'new_arrival'){
          _fetchLatestBooks();
      } else if (widget.pageType == 'category'){
          _fetchCatBooksByCat();
      } else if (widget.pageType == 'editor_choice'){
          _fetchCatBooksByEditor();
      } 
  }

  @override
  void initState() {
      super.initState();
      if (widget.pageType == 'category'){
        //maybe has pagination
        _fetchTotalPages().then((pageTotal){
            setState(() {
              totalPage = pageTotal;
            });
            Future.microtask(() { 
              _loadBooks();
            });
          });
      } else {
        _loadBooks();
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(detail: showingBooks[index]),
                        ));
                    },
                  );
                },
                childCount: showingBooks.length,
              ),
            ),
          ),
        ],
      )),
        bottomNavigationBar: (totalPage > 1) ? Card(
          margin: EdgeInsets.zero,
          child: NumberPaginator(
            // by default, the paginator shows numbers as center content
            numberPages: totalPage,
            onPageChange: (int index) { //start from 0
              setState(() {
                _currentPage = index;
              });
              Future.microtask(() { 
                _loadBooks();
              });
            },
          ),
        ) : null
      
    );
  }
}
