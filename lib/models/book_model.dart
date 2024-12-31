//author: Sang Do
import 'dart:convert';

class Book {
    String slug;
    late String title;
    late String cat;   //optional
    late String image; //cover url
    late String? isbn;
    late String? amazon;
    late String? author;
    late String? format;
    late String? others;  //list of other books
    late int? page_num;
    late String? age_range;
    late String? description;
    late String? illustration;
    late int? release_time;

  Book({
    this.isbn,
    this.amazon, 
    this.author, 
    this.format, 
    this.others, 
    this.page_num, 
    this.age_range, 
    this.description, 
    this.illustration, 
    this.release_time,
    required this.slug,
    required this.title,
    required this.cat,
    required this.image
  });

  Book.empty(this.slug);

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