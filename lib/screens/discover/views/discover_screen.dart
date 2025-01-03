import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

import 'components/expansion_category.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});


  @override
  State<DiscoverScreen> createState() => _PageState();
}

class _PageState extends State<DiscoverScreen> {
  List<CategoryModel> _categoryTree = [];
//setup Bottom Bar
  int _selectedBottomIndex = 1;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
    if (context.mounted){
      if (index == 0){
        Navigator.pushNamed(context, homeScreenRoute);  //Home page
      } else if (index == 2){
        Navigator.pushNamed(context, searchScreenRoute);  //Search page
      }
    }
  }
  //
  void _fetchMetadata() async{
    final _metadata = await DatabaseHelper.instance.rawQuery('SELECT categories FROM metadata', []);
    if (_metadata.isNotEmpty){
      List<dynamic> categories = jsonDecode(_metadata[0]['categories']);
      List<CategoryModel> categoryTree = [];
      Map<String, List<CategoryModel>> catMap = {};  //key: category name, value: list of sub cat
      //compose cat & sub cat list
      for (dynamic cat in categories){
        if (catMap[cat['name']] == null && cat['parent'] == null){
            catMap[cat['name']] = []; //init list
        }
        if (cat['parent'] != null){
          //this is a sub cat
          if (catMap[cat['parent']] == null){
            catMap[cat['parent']] = []; //init list
          }
          List<CategoryModel>? subCat = catMap[cat['parent']];
          subCat?.add(CategoryModel(title: cat['name']));
        }
      }
      //
      for (String cat_name in catMap.keys){
        categoryTree.add(CategoryModel(title: cat_name, subCategories: catMap[cat_name]));
      }
      //
      setState(() {
        _categoryTree = categoryTree;
      });
    }
  }
  //
  @override
  void initState() {
      super.initState();
      _fetchMetadata();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // While loading use 👇
            // const Expanded(
            //   child: DiscoverCategoriesSkelton(),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: _categoryTree.length,
                itemBuilder: (context, index) => ExpansionCategory(
                  title: _categoryTree[index].title,
                  subCategory: _categoryTree[index].subCategories!,
                ),
              ),
            )
          ],
        ),
      ),
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
