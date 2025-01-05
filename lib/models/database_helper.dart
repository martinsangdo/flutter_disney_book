//author: Sang Do
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/metadata_model.dart';
import 'package:sqflite/sqflite.dart';
import 'book_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'disney_book.db');

    // final file = File(path);
    // final size = file.lengthSync();
    // print('db size: ' + size.toString());  //MB = X / 1024 * 1024

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isbn TINYTEXT,
        amazon TINYTEXT,
        author TINYTEXT,
        format TINYTEXT,
        others TEXT,
        page_num INTEGER,
        age_range TINYTEXT,
        description TEXT,
        illustration TINYTEXT,
        release_time INTEGER,
        slug TINYTEXT,
        title TEXT,
        cat TINYTEXT,
        image TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TINYTEXT,
        books TEXT,
        categories TEXT,
        best_sellers TEXT,
        home_categories TEXT,
        affiliate_post_fix TEXT,
        update_time INTEGER
      )
    ''');
  }

  Future<int> insert(Book book) async {
    Database db = await instance.db;
    return await db.insert('book', book.toMap());
  }

  Future<List<Map>> queryBySlug(String slug) async {
    Database db = await instance.db;
    List<Map> result = await db.rawQuery('SELECT * FROM book WHERE slug=?', [slug]);
    return result;
  }

  Future<List<Map>> rawQuery(String query, List<String> conditions) async {
    Database db = await instance.db;
    return await db.rawQuery(query, conditions);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.db;
    return await db.query('book');
  }

  Future<int> update(Book book) async {
    Database db = await instance.db;
    return await db.update('book', book.toMap(), where: 'slug = ?', whereArgs: [book.slug]);
  }

  Future<int> upsert(Book newBook) async {
    Database db = await instance.db;
    String newSlug = newBook.slug;
    List<Map> result = await db.rawQuery('SELECT slug FROM book WHERE slug=?', [newSlug]);
    if (result.isEmpty){
      //insert new data
      return insert(newBook);
    } else {
      //update book
      return update(newBook);
    }
  }

  Future<int> delete(int id) async {
    Database db = await instance.db;
    return await db.delete('book', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map>> queryBookIn(List<dynamic> slugs) async {
    Database db = await instance.db;
    return await db.query('book', columns: ['*'], 
      where: 'slug IN (${slugs.map((e) => "?").join(', ')})', 
      whereArgs: slugs);
  }

  Future<List<Map>> queryByCat(String cat) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['*'],
      where: 'cat = ?',
      whereArgs: [cat],
      orderBy: "release_time DESC",
      limit: PAGE_SIZE
    );
    return result;
  }
  //get books by categories with pagination
  Future<List<Map>> queryByCatPagination(String cat, int pageIndex, int pageSize) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['*'],
      where: 'cat = ?',
      whereArgs: [cat],
      orderBy: "release_time DESC",
      limit: pageSize,
      offset: pageIndex * pageSize
    );
    return result;
  }
  //get books by categories with pagination
  Future<List<Map>> queryByCatTotal(String cat) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['count(*) AS total'],
      where: 'cat = ?',
      whereArgs: [cat]
    );
    return result;
  }
  //
  Future<List<Map>> queryLatestBooks(int pageIndex, int pageSize) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['*'],
      orderBy: "release_time DESC",
      limit: pageSize,
      offset: pageIndex * pageSize
    );
    return result;
  }
  //query by book format
  Future<List<Map>> queryByFormat(String format, int pageSize) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['*'],
      where: 'format = ?',
      whereArgs: [format],
      orderBy: "release_time DESC",
      limit: pageSize
    );
    return result;
  }
  //
  Future<List<Map>> searchBooks(String keyword, int pageSize) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['*'],
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: "release_time DESC",
      limit: pageSize
    );
    return result;
  }
  //update or insert books at once
  void upsertBatch(List<Book> books) async {
    var dbBatch = _database?.batch();
    List<Book> list2Insert = [];
    List<Book> list2Update = [];
    List<String> slugs = [];  //all slugs
    Map<String, Book> newBooks = {};  //key: slug, value: Book detail
    for (Book book in books){
      slugs.add(book.slug);
      newBooks[book.slug] = book;
    }
    if (dbBatch != null){
      final dbBooks = await DatabaseHelper.instance.queryBookIn(slugs);
      if (dbBooks.isNotEmpty){
        List<String> slugsInDb = [];  //all slugs in db
        for (Map dbBook in dbBooks){
          slugsInDb.add(dbBook['slug']);
          if (slugs.contains(dbBook['slug']) && newBooks[dbBook['slug']] != null){
            list2Update.add(newBooks[dbBook['slug']]!);  //update new book detail
          }
        }
        for (Book book in books){
          if (!slugsInDb.contains(book.slug)){
            list2Insert.add(book);  //new books
          }
        }
      } else {
        //nothing in db
        for (Book book in books){
          list2Insert.add(book);  //new books
        }
      }
    } else {
      debugPrint('dbBatch null ');
    }
    debugPrint('list2Insert ' + list2Insert.length.toString());
    debugPrint('list2Update ' + list2Update.length.toString());

    if (list2Insert.isNotEmpty){
      for (Book book in list2Insert){
        dbBatch?.insert('book', book.toMap());
      }
    }
    if (list2Update.isNotEmpty){
      for (Book book in list2Update){
        dbBatch?.update('book', book.toMap(), where: 'slug = ?', whereArgs: [book.slug]);
      }
    }
    await dbBatch?.commit();
  }
  /////////////// METADATA
  Future<int> insertMetadata(MetaDataModel newMetadata) async {
    Database db = await instance.db;
    return await db.insert('metadata', newMetadata.toMap());
  }
  Future<int> updateMetadata(MetaDataModel newMetadata) async {
    Database db = await instance.db;
    return await db.update('metadata', newMetadata.toMap(), where: 'uuid = ?', whereArgs: [newMetadata.uuid]);
  }
  ///// BATCH
  // Future<List<Map>> batchQueries() async {
  //   Database db = await instance.db;
  //   var batch = _database.batch();
  //   batch.rawInsert(statement1);
  //   batch.rawInsert(statement2);
  //   batch.rawInsert(statement3);
  //   ...
  //   await db.commit(noResult: true);
  // }
}
