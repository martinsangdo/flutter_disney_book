//author: Sang Do
import 'dart:convert';

class MetaDataModel {
    final String uuid;  //random unique ID because Metadata has only 1 record
    final String books; //link to book data
    final String categories;  //all categories hierachy
    final int update_time; //the time we update this record in db (sec)
    final String best_sellers;  //list of books
    final String home_categories; //categories names that showing in home page
    final String affiliate_post_fix;  //params that will be appended into each book link in Amazon

  MetaDataModel({
    required this.uuid,
    required this.books, 
    required this.categories,
    required this.update_time,
    required this.best_sellers,
    required this.home_categories,
    required this.affiliate_post_fix
  });

  factory MetaDataModel.fromJson(Map<String, dynamic> json) {
    return MetaDataModel(
      uuid: json['uuid'] as String,
      books: json['books'] as String,
      categories: jsonEncode(json['categories']),
      update_time: json['update_time'] as int,
      best_sellers: jsonEncode(json['best_sellers']),
      home_categories: jsonEncode(json['home_categories']),
      affiliate_post_fix: jsonEncode(json['affiliate_post_fix'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'books': books,
      'categories': categories,
      'update_time': update_time,
      'best_sellers': best_sellers,
      'home_categories': home_categories,
      'affiliate_post_fix': affiliate_post_fix
      };
  }

  factory MetaDataModel.fromMap(Map<String, dynamic> map) {
    return MetaDataModel(
      uuid: map['uuid'],
      books: map['books'],
      categories: map['categories'],
      update_time: map['update_time'],
      best_sellers: map['best_sellers'],
      home_categories: map['home_categories'],
      affiliate_post_fix: map['affiliate_post_fix']
    );
  }
}