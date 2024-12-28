//author: Sang Do
import 'dart:convert';

class Book {
    final String slug;
    final String title;

    final String cat;   //optional
    final String image; //cover url
    final String isbn;
    final String amazon;
    final String author;
    final String format;
    final String? others;  //list of other books
    final int page_num;
    final String age_range;
    final String description;
    final String illustration;
    final int release_time;

  Book({
    required this.isbn,
    required this.amazon, 
    required this.author, 
    required this.format, 
    required this.others, 
    required this.page_num, 
    required this.age_range, 
    required this.description, 
    required this.illustration, 
    required this.release_time,
    required this.slug,
    required this.title,
    required this.cat,
    required this.image
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // List<OtherBooks> others = List.empty();
    // if (json['others'] != null){
    //   others = json['others'].map<OtherBooks>((json) => OtherBooks.fromJson(json)).toList();
    // }
    int page_num = 0;
    if (json['page_num'] != null && json['page_num'] != ""){
      page_num = int.parse(json['page_num']);
    }
    return Book(
      isbn: json['isbn'] as String,
      amazon: json['amazon'] as String,
      author: json['author'] as String,
      format: json['format'] as String,
      others: jsonEncode(json['others']),
      page_num: page_num,
      age_range: json['age_range'] as String,
      description: json['description'] as String,
      illustration: json['illustration'] as String,
      release_time: json['release_time'] as int,
      slug: json['slug'] as String,
      title: json['title'] as String,
      cat: json['cat'] as String,
      image: json['image'] as String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'amazon': amazon,
      'author': author,
      'format': format,
      'others': others,
      'page_num': page_num,
      'age_range': age_range,
      'description': description,
      'illustration': illustration,
      'release_time': release_time,
      'slug': slug, 
      'title': title, 
      'cat': cat, 
      'image': image};
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      isbn: map['isbn'],
      amazon: map['amazon'],
      author: map['author'],
      format: map['format'],
      others: map['others'],
      page_num: map['page_num'],
      age_range: map['age_range'],
      description: map['description'],
      illustration: map['illustration'],
      release_time: map['release_time'],
      slug: map['slug'],
      title: map['title'],
      cat: map['cat'],
      image: map['image']
    );
  }
}