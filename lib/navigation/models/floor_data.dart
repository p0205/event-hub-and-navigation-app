class FloorData {
  final String name;
  final int floorId;
  final String svgPath;
  final String? imageUrl;

  const FloorData({
    required this.name,
    required this.floorId,
    required this.svgPath,
    this.imageUrl,
  });

  factory FloorData.fromJson(Map<String, dynamic> json) {
    return FloorData(
      name: json['name'] as String,
      floorId: json['id'],
      svgPath: json['svg_path'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id':floorId,
      'svg_path': svgPath,
      'image_url': imageUrl,
    };
  }
} 