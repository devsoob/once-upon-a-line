class StoryStarter {
  final String id;
  final String genre;
  final String content;

  StoryStarter({required this.id, required this.genre, required this.content});

  StoryStarter copyWith({String? id, String? genre, String? content}) {
    return StoryStarter(
      id: id ?? this.id,
      genre: genre ?? this.genre,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'genre': genre, 'content': content};
  }

  static StoryStarter fromJson(Map<String, dynamic> json) {
    return StoryStarter(
      id: json['id'] ?? '',
      genre: json['genre'] ?? '',
      content: json['content'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryStarter &&
        other.id == id &&
        other.genre == genre &&
        other.content == content;
  }

  @override
  int get hashCode {
    return id.hashCode ^ genre.hashCode ^ content.hashCode;
  }
}
