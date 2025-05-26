class Feedback {
  final int? userId;
  final int rating;
  final String? comment;

  Feedback({this.userId, required this.rating, required this.comment});
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      userId: json["userId"],
      rating: json["rating"],
      comment: json["comment"] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {"userId": userId, "rating": rating, "comment": comment};
  }
}
