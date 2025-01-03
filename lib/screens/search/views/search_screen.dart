import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/product/views/product_details_screen.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _keyword = '';  //search by title or description, min 3 chars
  List<Book> showingBooks = [];
  String errorMessage = '';
  //setup Bottom Bar
  int _selectedBottomIndex = 2;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
    if (context.mounted){
      if (index == 0){
        Navigator.pushNamed(context, homeScreenRoute);  //Home page
      } else if (index == 1){
        Navigator.pushNamed(context, discoverScreenRoute);  //Categories page
      }
    }
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
  //when user types into the search text box
  String _onChange(value){
    setState(() {
      _keyword = value.trim();
    });
    return "";
  }
  //
  void searchData() async{
    //begin searching
    var books = await DatabaseHelper.instance.searchBooks(_keyword, DOUBLE_PAGE_SIZE);
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
          });
    } else {
        setState(() {
            errorMessage = 'No result';
        });
    }
  }
  //
  //when user taps Search
  String _onSubmit(value){
    String keyword = value.trim();
    if (keyword.length < 3){
      setState(() {
        errorMessage = 'Please input min 3 characters';
      });
      return "";  //do nothing
    }
    setState(() {
      errorMessage = '';  //clear status
    });
    searchData();
    return "";
  }
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SearchForm(onChanged: _onChange, onFieldSubmitted: _onSubmit),
            ),
            if (errorMessage.isNotEmpty) Text(errorMessage, style: const TextStyle(color: Colors.red)),
            Expanded(
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
              ],  //end slivers
            ),  //end ScrollView
          )], //end Expand
        ),
      ),//end body
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
