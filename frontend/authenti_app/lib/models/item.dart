class Item {
  final String? id;
  final String title;
  final bool isDone;
  final String userId; // Reference to the user who owns this item
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    this.id,
    required this.title,
    this.isDone = false,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create Item from JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      isDone: json['isDone'] ?? false,
      userId: json['user'] ?? json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Method to convert Item to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'isDone': isDone,
      'user': userId,
    };

    if (id != null) data['_id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    return data;
  }

  // Method to create a copy of Item with some fields updated
  Item copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Item{id: $id, title: $title, isDone: $isDone, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
