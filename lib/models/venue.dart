

class Venue {
  final int id;
  final String name;
  final String? nodeId; // Identifier for navigation (e.g., node ID on a map)

  Venue({required this.id, required this.name,  this.nodeId});

  // You would typically add a fromJson factory constructor here
  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'] as String,
      nodeId: json['nodeId'] as String?,
    );
  }

  static List<Venue> fromJsonArray(List<dynamic> jsonArray){
    return jsonArray.map((json) => Venue.fromJson(json)).toList();
  }
}