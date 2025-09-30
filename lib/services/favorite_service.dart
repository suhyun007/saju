import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models/favorite.dart';
import 'database_helper.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 즐겨찾기 변경 스트림 (추가/삭제/업데이트 알림)
  final StreamController<FavoriteChange> _changeController = StreamController<FavoriteChange>.broadcast();
  Stream<FavoriteChange> get changes => _changeController.stream;

  // 즐겨찾기 추가
  Future<int> addFavorite(Favorite favorite) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.insert(
        'favorite_list',
        favorite.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 교체
      );
      if (result > 0) {
        _changeController.add(FavoriteChange(
          action: FavoriteAction.added,
          guestId: favorite.guestId,
          saveDtYmd: favorite.saveDt,
          menuType: favorite.menuType,
          title: favorite.title,
        ));
      }
      return result;
    } catch (e) {
      print('즐겨찾기 추가 오류: $e');
      rethrow;
    }
  }

  // 즐겨찾기 조회 (특정 게스트의 모든 즐겨찾기)
  Future<List<Favorite>> getFavoritesByGuestId(String guestId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'favorite_list',
        where: 'guest_id = ?',
        whereArgs: [guestId],
        orderBy: 'save_dt DESC, menu_type DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return Favorite.fromMap(maps[i]);
      });
    } catch (e) {
      print('즐겨찾기 조회 오류: $e');
      return [];
    }
  }

  // 즐겨찾기 조회 (특정 게스트의 특정 타입만)
  Future<List<Favorite>> getFavoritesByGuestIdAndType(String guestId, String menuType) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'favorite_list',
        where: 'guest_id = ? AND menu_type = ?',
        whereArgs: [guestId, menuType],
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return Favorite.fromMap(maps[i]);
      });
    } catch (e) {
      print('즐겨찾기 조회 오류: $e');
      return [];
    }
  }

  // 즐겨찾기 삭제
  Future<int> deleteFavorite(int id) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'favorite_list',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('즐겨찾기 삭제 오류: $e');
      rethrow;
    }
  }

  // 즐겨찾기 삭제 (제목과 타입으로)
  Future<int> deleteFavoriteByTitleAndType(String guestId, String title, String menuType) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'favorite_list',
        where: 'guest_id = ? AND title = ? AND menu_type = ?',
        whereArgs: [guestId, title, menuType],
      );
    } catch (e) {
      print('즐겨찾기 삭제 오류: $e');
      rethrow;
    }
  }

  // 즐겨찾기 추가 (동일 guest_id + save_dt + menu_type + title 있으면 미삽입)
  Future<int> addIfNotExists({
    required String guestId,
    required String saveDtYmd,
    required String menuType,
    required String title,
    required String content,
    bool isExperience = false,
  }) async {
    try {
      final db = await _dbHelper.database;
      // 존재 여부 확인 (UNIQUE 제약조건과 동일하게)
      final exists = await db.query(
        'favorite_list',
        columns: const ['id'],
        where: 'guest_id = ? AND menu_type = ? AND title = ?',
        whereArgs: [guestId, menuType, title],
        limit: 1,
      );
      if (exists.isNotEmpty) {
        return 0; // 이미 존재
      }
      final result = await db.insert('favorite_list', {
        'guest_id': guestId,
        'save_dt': saveDtYmd,
        'menu_type': menuType,
        'title': title,
        'content': content,
        'is_experience': isExperience ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (result > 0) {
        _changeController.add(FavoriteChange(
          action: FavoriteAction.added,
          guestId: guestId,
          saveDtYmd: saveDtYmd,
          menuType: menuType,
          title: title,
        ));
      }
      return result;
    } catch (e) {
      print('즐겨찾기 조건부 추가 오류: $e');
      rethrow;
    }
  }
  // 체험모드 즐겨찾기 일괄 삭제 (해당 guest)
  Future<int> deleteExperienceFavorites(String guestId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'favorite_list',
        where: 'guest_id = ? AND is_experience = 1',
        whereArgs: [guestId],
      );
      return result;
    } catch (e) {
      print('체험모드 즐겨찾기 삭제 오류: $e');
      rethrow;
    }
  }

  // 즐겨찾기 삭제 (guest_id + save_dt + menu_type + title)
  Future<int> deleteByComposite({
    required String guestId,
    required String saveDtYmd,
    required String menuType,
    required String title,
  }) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'favorite_list',
        where: 'guest_id = ? AND save_dt = ? AND menu_type = ? AND title = ?',
        whereArgs: [guestId, saveDtYmd, menuType, title],
      );
      if (result > 0) {
        _changeController.add(FavoriteChange(
          action: FavoriteAction.deleted,
          guestId: guestId,
          saveDtYmd: saveDtYmd,
          menuType: menuType,
          title: title,
        ));
      }
      return result;
    } catch (e) {
      print('즐겨찾기 복합키 삭제 오류: $e');
      rethrow;
    }
  }

  // 즐겨찾기 존재 여부 (guest_id + save_dt + menu_type + title)
  Future<bool> isFavoriteByDate(String guestId, String saveDtYmd, String title, String menuType) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        'favorite_list',
        columns: const ['id'],
        where: 'guest_id = ? AND save_dt = ? AND title = ? AND menu_type = ?',
        whereArgs: [guestId, saveDtYmd, title, menuType],
        limit: 1,
      );
      return rows.isNotEmpty;
    } catch (e) {
      print('즐겨찾기(날짜 포함) 확인 오류: $e');
      return false;
    }
  }

  // 즐겨찾기 존재 여부 확인
  Future<bool> isFavorite(String guestId, String title, String menuType) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'favorite_list',
        where: 'guest_id = ? AND title = ? AND menu_type = ?',
        whereArgs: [guestId, title, menuType],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('즐겨찾기 확인 오류: $e');
      return false;
    }
  }

  // 즐겨찾기 업데이트
  Future<int> updateFavorite(Favorite favorite) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
        'favorite_list',
        favorite.toMap(),
        where: 'id = ?',
        whereArgs: [favorite.id],
      );
      if (result > 0) {
        _changeController.add(FavoriteChange(
          action: FavoriteAction.updated,
          guestId: favorite.guestId,
          saveDtYmd: favorite.saveDt,
          menuType: favorite.menuType,
          title: favorite.title,
        ));
      }
      return result;
    } catch (e) {
      print('즐겨찾기 업데이트 오류: $e');
      rethrow;
    }
  }

  // 즐겨찾기 개수 조회
  Future<int> getFavoriteCount(String guestId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM favorite_list WHERE guest_id = ?',
        [guestId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('즐겨찾기 개수 조회 오류: $e');
      return 0;
    }
  }

  // 즐겨찾기 개수 조회 (타입별)
  Future<int> getFavoriteCountByType(String guestId, String menuType) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM favorite_list WHERE guest_id = ? AND menu_type = ?',
        [guestId, menuType],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('즐겨찾기 개수 조회 오류: $e');
      return 0;
    }
  }

  // 모든 즐겨찾기 삭제 (특정 게스트)
  Future<int> deleteAllFavorites(String guestId) async {
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'favorite_list',
        where: 'guest_id = ?',
        whereArgs: [guestId],
      );
    } catch (e) {
      print('모든 즐겨찾기 삭제 오류: $e');
      rethrow;
    }
  }
}

enum FavoriteAction { added, deleted, updated }

class FavoriteChange {
  final FavoriteAction action;
  final String guestId;
  final String saveDtYmd;
  final String menuType;
  final String title;

  FavoriteChange({
    required this.action,
    required this.guestId,
    required this.saveDtYmd,
    required this.menuType,
    required this.title,
  });
}
