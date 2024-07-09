class Note {
  String title;
  String content;
  DateTime lastEdited;
  List<String> tags;
  bool isDeleted; // Yeni alan

  Note({
    required this.title,
    required this.content,
    required this.lastEdited,
    required this.tags,
    this.isDeleted = false, // Varsayılan olarak false
  });

  get deletedDate => null;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'lastEdited': lastEdited.toIso8601String(),
      'tags': tags,
      'isDeleted': isDeleted,
    };
  }

  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      lastEdited: DateTime.parse(json['lastEdited']),
      tags: List<String>.from(json['tags']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
