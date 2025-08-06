// lib/services/database_service.dart
// database service for news page and its model
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/news_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'news_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE news(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        content TEXT,
        category TEXT NOT NULL,
        slug TEXT NOT NULL UNIQUE,
        image_url TEXT,
        source_url TEXT NOT NULL,
        published_at TEXT NOT NULL,
        created_at TEXT,
        saved_at TEXT NOT NULL
      )
    ''');

    // Create index for better performance
    await db.execute('CREATE INDEX idx_category ON news(category)');
    await db.execute('CREATE INDEX idx_published_at ON news(published_at)');
  }

  // Save news articles to database
  Future<void> saveNews(List<NewsModel> articles) async {
    final db = await database;
    final batch = db.batch();

    for (NewsModel article in articles) {
      var map = article.toMap();
      map['saved_at'] = DateTime.now().toIso8601String();

      batch.insert('news', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  // Get all saved news
  Future<List<NewsModel>> getAllNews({int? limit, String? category}) async {
    final db = await database;

    String query = 'SELECT * FROM news';
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereConditions.add('category = ?');
      whereArgs.add(category);
    }

    if (whereConditions.isNotEmpty) {
      query += ' WHERE ${whereConditions.join(' AND ')}';
    }

    query += ' ORDER BY published_at DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);
    return List.generate(maps.length, (i) => NewsModel.fromMap(maps[i]));
  }

  // Get news by category
  Future<List<NewsModel>> getNewsByCategory(
    String category, {
    int? limit,
  }) async {
    return await getAllNews(category: category, limit: limit);
  }

  // Get single news by slug
  Future<NewsModel?> getNewsBySlug(String slug) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'news',
      where: 'slug = ?',
      whereArgs: [slug],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return NewsModel.fromMap(maps.first);
    }
    return null;
  }

  // Search news
  Future<List<NewsModel>> searchNews(
    String query, {
    String? category,
    int? limit,
  }) async {
    final db = await database;

    String sql = '''
      SELECT * FROM news 
      WHERE (title LIKE ? OR description LIKE ?)
    ''';
    List<dynamic> args = ['%$query%', '%$query%'];

    if (category != null) {
      sql += ' AND category = ?';
      args.add(category);
    }

    sql += ' ORDER BY published_at DESC';

    if (limit != null) {
      sql += ' LIMIT $limit';
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return List.generate(maps.length, (i) => NewsModel.fromMap(maps[i]));
  }

  // Delete old news (keep only recent ones)
  Future<void> cleanOldNews({int daysToKeep = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      'news',
      where: 'saved_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Get news count
  Future<int> getNewsCount({String? category}) async {
    final db = await database;

    String query = 'SELECT COUNT(*) FROM news';
    List<dynamic> args = [];

    if (category != null) {
      query += ' WHERE category = ?';
      args.add(category);
    }

    final result = await db.rawQuery(query, args);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
