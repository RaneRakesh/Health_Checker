class UserProfile {
  int? age;
  String? gender;
  double? height; // cm
  double? weight; // kg
  // Add more fields as needed for MVP

  UserProfile({this.age, this.gender, this.height, this.weight});

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        age: json['age'] as int?,
        gender: json['gender'] as String?,
        height: (json['height'] as num?)?.toDouble(),
        weight: (json['weight'] as num?)?.toDouble(),
      );
}
