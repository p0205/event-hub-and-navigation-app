class User {
  final int id;
  final String? name;
  final String? email;
  final String? faculty;
  final String? phoneNo;
  final String? gender;
  final String? course;
  final String? year;
  final String? role;
  final bool? mustChangePassword;

  User(
      {required this.id,
      this.name,
      this.email,
      this.faculty,
      this.phoneNo,
      this.gender,
      this.course,
      this.year,
      this.role,
      this.mustChangePassword});

  // Factory method to create a User from a JSON object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        faculty: json['faculty'],
        gender: json['gender'],
        phoneNo: json['phoneNo'],
        course: json['course'],
        year: json['year'],
        role: json['role'],
        mustChangePassword: json['mustChangePassword']);
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'faculty': faculty,
      'gender': gender,
      'phoneNo': phoneNo,
      'course': course,
      'year': year,
      'role': role,
      'mustChangePassword': mustChangePassword
    };
  }

  User copyWith(
      {int? id,
      String? name,
      String? email,
      String? faculty,
      String? phoneNo,
      String? gender,
      String? course,
      String? year,
      String? role,
      bool? mustChangePassword

      // ... other fields
      }) {
    return User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        gender: gender ?? this.gender,
        faculty: faculty ?? this.faculty,
        phoneNo: phoneNo ?? this.phoneNo,
        course: course ?? this.course,
        year: year ?? this.year,
        role: role ?? this.role,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword);
  }
}
