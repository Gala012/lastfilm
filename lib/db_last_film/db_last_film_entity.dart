class RollEntity {
  final int? id;
  final String name;
  final String filmId;
  final String? coverPath;
  final int createdAt;
  final int category;

  RollEntity({
    this.id,
    required this.name,
    required this.filmId,
    this.coverPath,
    required this.createdAt,
    this.category = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'film_id': filmId,
      'cover_path': coverPath,
      'created_at': createdAt,
      'category': category,
    };
  }

  factory RollEntity.fromMap(Map<String, dynamic> map) {
    return RollEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      filmId: map['film_id'] as String,
      coverPath: map['cover_path'] as String?,
      createdAt: map['created_at'] as int,
      category: map['category'] as int? ?? 0,
    );
  }
}

class PhotoEntity {
  final int? id;
  final int rollId;
  final String filePath;
  final int createdAt;

  PhotoEntity({
    this.id,
    required this.rollId,
    required this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roll_id': rollId,
      'file_path': filePath,
      'created_at': createdAt,
    };
  }

  factory PhotoEntity.fromMap(Map<String, dynamic> map) {
    return PhotoEntity(
      id: map['id'] as int?,
      rollId: map['roll_id'] as int,
      filePath: map['file_path'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}
