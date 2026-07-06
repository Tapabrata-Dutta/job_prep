class ApplicationItem {
  final int id;
  final String name;
  final bool applied;
  final String status;

  ApplicationItem({
    required this.id,
    required this.name,
    required this.applied,
    required this.status,
  });

  factory ApplicationItem.fromJson(Map<String, dynamic> json) {
    bool parseApplied(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final lower = value.toLowerCase().trim();
        return ["true", "1", "yes", "y", "done", "applied"].contains(lower);
      }
      return false;
    }

    return ApplicationItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      applied: parseApplied(json['applied']),
      status: json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'applied': applied,
      'status': status,
    };
  }
}
