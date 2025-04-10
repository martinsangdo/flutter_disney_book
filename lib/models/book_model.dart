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
    // late bool? isBookmarked;  //user bookmarked this book or not

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

  int getCurrentTimestampInSeconds() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Book.empty(this.slug);
  //parse JSON data into Book object
  factory Book.fromJson(Map<String, dynamic> json) {
    int page_num = 0;
    if (json['page_num'] != null && json['page_num'] != "" && json['page_num'] != "Boxed Set"){
      page_num = int.parse(json['page_num']);
    }
    String isbn = "";
    if (json['isbn'] != null){
      isbn = json['isbn'];
    }
    String age_range = "";
    if (json['age_range'] != null){
      age_range = json['age_range'];
    }
    String illustration = "";
    if (json['illustration'] != null){
      illustration = json['illustration'];
    }
    String format = "";
    if (json['format'] != null){
      format = json['format'];
    }
    String author = "";
    if (json['author'] != null){
      author = json['author'];
    }
    int release_time = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (json['release_time'] != null){
      release_time = json['release_time'];
    }

    return Book(
      isbn: isbn,
      amazon: json['amazon'] as String,
      author: author,
      format: format,
      others: jsonEncode(json['others']),
      page_num: page_num,
      age_range: age_range,
      description: json['description'] as String,
      illustration: illustration,
      release_time: release_time,
      slug: json['slug'] as String,
      title: json['title'] as String,
      cat: json['cat'] as String,
      image: json['image'] as String
    );
  }
  //convert
  factory Book.convert(Map<dynamic, dynamic> map) {
    // int page_num = 0;
    // if (map['page_num'] != null && map['page_num'] != ""){
    //   page_num = intmap['page_num']);
    // }
    return Book(
      isbn: map['isbn'] as String,
      amazon: map['amazon'] as String,
      author: map['author'] as String,
      format: map['format'] as String,
      others: jsonEncode(map['others']),
      page_num: map['page_num'] as int,
      age_range: map['age_range'] as String,
      description: map['description'] as String,
      illustration: map['illustration'] as String,
      release_time: map['release_time'] as int,
      slug: map['slug'] as String,
      title: map['title'] as String,
      cat: map['cat'] as String,
      image: map['image'] as String
    );
  }
  //convert to book detail before saving to DB
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