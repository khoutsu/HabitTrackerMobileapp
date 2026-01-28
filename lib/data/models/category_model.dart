class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  Category copyWith({int? id, String? name}) {
    return Category(id: id ?? this.id, name: name ?? this.name);
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}
