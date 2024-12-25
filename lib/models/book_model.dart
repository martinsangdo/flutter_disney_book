//author: Sang Do
class Book {
    final String slug;
    final String title;

    final String cat;   //optional
    final String image; //cover url

  Book({
    required this.slug,
    required this.title,
    required this.cat,
    required this.image
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      slug: json['slug'] as String,
      title: json['title'] as String,
      cat: json['cat'] as String,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'slug': slug, 'title': title, 'cat': cat, 'image': image};
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      slug: map['slug'],
      title: map['title'],
      cat: map['cat'],
      image: map['image']
    );
  }
}