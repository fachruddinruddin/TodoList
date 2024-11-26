import 'package:latihan4_todolist/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    try {
      io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'todolist.db');
      var theDb = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      return theDb;
    } catch (e) {
      throw Exception('Database initialization error: $e');
    }
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Todo>> getAllTodos() async {
    try {
      var dbClient = await db;
      var todos = await dbClient!.query('todos');
      return todos.map((todo) => Todo.fromMap(todo)).toList();
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }

  Future<Todo> getTodoById(int id) async {
    try {
      var dbClient = await db;
      var todo = await dbClient!.query('todos', where: 'id = ?', whereArgs: [id]);
      if (todo.isNotEmpty) {
        return Todo.fromMap(todo.first);
      } else {
        throw Exception('Todo not found');
      }
    } catch (e) {
      throw Exception('Error fetching todo by id: $e');
    }
  }

  Future<List<Todo>> getTodoByTitle(String title) async {
    try {
      var dbClient = await db;
      var todos = await dbClient!.query('todos', where: 'title LIKE ?', whereArgs: ['%$title%']);
      return todos.map((todo) => Todo.fromMap(todo)).toList();
    } catch (e) {
      throw Exception('Error fetching todos by title: $e');
    }
  }

  Future<int> insertTodo(Todo todo) async {
    try {
      var dbClient = await db;
      return await dbClient!.insert('todos', todo.toMap());
    } catch (e) {
      throw Exception('Error inserting todo: $e');
    }
  }

  Future<int> updateTodo(Todo todo) async {
    try {
      var dbClient = await db;
      return await dbClient!.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }

  Future<int> deleteTodo(int id) async {
    try {
      var dbClient = await db;
      return await dbClient!.delete('todos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }
}