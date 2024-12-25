//author: Sang Do
class Book {
    final String slug;
    final String title;

    final String cat;   //optional
    final String image; //cover url

  const Book({
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

  
}