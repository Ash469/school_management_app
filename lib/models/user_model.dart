class User {
  final String id;
  final String email;
  final String role;
  final UserProfile profile;
  final String schoolToken;
  final String schoolName;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.profile,
    required this.schoolToken,
    required this.schoolName,
  });
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
}
