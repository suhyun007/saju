class Favorite {
  final int? id;
  final String guestId;
  final String saveDt;
  final String menuType; // 'episode' 또는 'poetry'
  final String title;
  final String content;
  final String? memo; // 메모 (최대 1000자)
  final bool isExperience; // 체험모드에서 저장된 항목 여부
  final String createdAt;

  Favorite({
    this.id,
    required this.guestId,
    required this.saveDt,
    required this.menuType,
    required this.title,
    required this.content,
    this.memo,
    this.isExperience = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guest_id': guestId,
      'save_dt': saveDt,
      'menu_type': menuType,
      'title': title,
      'content': content,
      'memo': memo,
      'is_experience': isExperience ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      guestId: map['guest_id'],
      saveDt: map['save_dt'],
      menuType: map['menu_type'],
      title: map['title'],
      content: map['content'],
      memo: map['memo'],
      isExperience: (map['is_experience'] ?? 0) == 1,
      createdAt: map['created_at'],
    );
  }

  Favorite copyWith({
    int? id,
    String? guestId,
    String? saveDt,
    String? menuType,
    String? title,
    String? content,
    String? memo,
    bool? isExperience,
    String? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      saveDt: saveDt ?? this.saveDt,
      menuType: menuType ?? this.menuType,
      title: title ?? this.title,
      content: content ?? this.content,
      memo: memo ?? this.memo,
      isExperience: isExperience ?? this.isExperience,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Favorite(id: $id, guestId: $guestId, saveDt: $saveDt, menuType: $menuType, title: $title, content: $content, memo: $memo, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite &&
        other.id == id &&
        other.guestId == guestId &&
        other.saveDt == saveDt &&
        other.menuType == menuType &&
        other.title == title &&
        other.content == content &&
        other.memo == memo &&
        other.isExperience == isExperience &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        guestId.hashCode ^
        saveDt.hashCode ^
        menuType.hashCode ^
        title.hashCode ^
        content.hashCode ^
        memo.hashCode ^
        isExperience.hashCode ^
        createdAt.hashCode;
  }
}
