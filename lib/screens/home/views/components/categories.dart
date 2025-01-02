import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/models/database_helper.dart';
import 'package:shop/route/screen_export.dart';

import '../../../../constants.dart';

// For preview
class CategoryModel {
  final String name;
  final String? svgSrc, route;

  CategoryModel({
    required this.name,
    this.svgSrc,
    this.route,
  });
}
/*
List<CategoryModel> demoCategories = [
  CategoryModel(name: "All Categories"),
  CategoryModel(
      name: "On Sale",
      svgSrc: "assets/icons/Sale.svg",
      route: onSaleScreenRoute),
  CategoryModel(name: "Man's", svgSrc: "assets/icons/Man.svg"),
  CategoryModel(name: "Woman’s", svgSrc: "assets/icons/Woman.svg"),
  CategoryModel(
      name: "Kids", svgSrc: "assets/icons/Child.svg", route: kidsScreenRoute),
];
*/
// End For Preview

class Categories extends StatefulWidget {
  const Categories({
    super.key,
  });
 @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<CategoryModel> _homeCategories = [];

  @override
  void initState() {
      super.initState();
      _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    final _metadata = await DatabaseHelper.instance.rawQuery('SELECT home_categories FROM metadata', []);
    if (_metadata.isNotEmpty){
      // debugPrint(_metadata[0]['home_categories']);
      var home_categories = jsonDecode(_metadata[0]['home_categories']);
      List<CategoryModel> _homeCat = [];
      _homeCat.add(CategoryModel(name: "All categories"));  //default
      for (String home_category in home_categories){
        _homeCat.add(CategoryModel(name: home_category));
      }
      setState(() {
        _homeCategories = _homeCat;
      });
    } else {

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            _homeCategories.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                  left: index == 0 ? defaultPadding : defaultPadding / 2,
                  right:
                      index == _homeCategories.length - 1 ? defaultPadding : 0),
              child: CategoryBtn(
                category: _homeCategories[index].name,
                svgSrc: _homeCategories[index].svgSrc,
                isActive: index == 0,
                press: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookmarkScreen(appBarTitle: _homeCategories[index].name, pageType: 'category')
                          ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBtn extends StatelessWidget {
  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            if (svgSrc != null) const SizedBox(width: defaultPadding / 2),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
