import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'saju_app.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // favorite_list 테이블 생성
    await db.execute('''
      CREATE TABLE favorite_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_id TEXT NOT NULL,
        save_dt TEXT NOT NULL,
        menu_type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        memo TEXT,
        is_experience INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 인덱스 생성
    await db.execute('''
      CREATE INDEX idx_favorite_guest_id ON favorite_list(guest_id)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_favorite_menu_type ON favorite_list(menu_type)
    ''');

    // 중복 방지를 위한 유니크 인덱스 (같은 게스트가 같은 제목의 같은 타입을 중복 저장 방지)
    await db.execute('''
      CREATE UNIQUE INDEX idx_favorite_unique ON favorite_list(guest_id, title, menu_type)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // memo 컬럼 추가
      await db.execute('''
        ALTER TABLE favorite_list ADD COLUMN memo TEXT
      ''');
    }
    if (oldVersion < 3) {
      // 체험모드 플래그 컬럼 추가
      await db.execute('''
        ALTER TABLE favorite_list ADD COLUMN is_experience INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
