

class Venue {
  final String id;
  final String name;
  final String nodeId; // Identifier for navigation (e.g., node ID on a map)

  Venue({required this.id, required this.name, required this.nodeId});

  // You would typically add a fromJson factory constructor here
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      nodeId: json['nodeId'] as String,
    );
  }
}