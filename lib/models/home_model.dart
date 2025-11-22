class Home {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;

  Home({
    required this.id,
    required this.name,
    required this.ownerId,
    this.memberIds = const [],
  });

  Home copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? memberIds,
  }) {
    return Home(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}
