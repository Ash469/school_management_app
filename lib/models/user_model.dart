class User {
  final String id;
  final String email;
  final String role;
  final UserProfile profile;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profile: UserProfile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'profile': profile.toJson(),
    };
  }
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String profilePicture;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      profilePicture: json['profilePicture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
    };
  }
}
