class Todo {
  final String id;
  final String title;
  final bool isDone;

  Todo({required this.id, required this.title, required this.isDone});

  factory Todo.fromMap(Map<String, dynamic> m) => Todo(
    id: m['_id'] ?? m['id'],
    title: m['title'],
    isDone: m['isDone'] ?? false,
  );
}
