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
  //
  Future<List<Map>> queryLatestBooks(int pageIndex, int pageSize) async {
    Database db = await instance.db;
    List<Map> result = await db.query('book',
      columns: ['*'],
      orderBy: "release_time DESC",
      limit: PAGE_SIZE,
      offset: pageIndex * pageSize
    );
    return result;
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
}
