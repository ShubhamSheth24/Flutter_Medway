// import 'package:flutter/material.dart';

// class UserModel with ChangeNotifier {
//   String? name;
//   String? email;
//   String? role;

//   get profileImageUrl => null;

//   void setUser(String name, String email, String? role) {
//     this.name = name;
//     this.email = email;
//     this.role = role;
//     notifyListeners();
//   }

//   void clearUser() {
//     name = null;
//     email = null;
//     role = null;
//     notifyListeners();
//   }

//   void updateName(String userName) {}

//   void updateProfileImage(param0) {}

//   void setRole(param0) {}

//   void updateRole(data) {}
// }
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String? _name;
  String? _email;
  String? _role;
  String? _profileImageUrl;

  // Getters
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  String? get profileImageUrl => _profileImageUrl;

  // Set initial user data
  void setUser(String name, String email, String? role) {
    _name = name;
    _email = email;
    _role = role;
    notifyListeners();
  }

  // Clear user data
  void clearUser() {
    _name = null;
    _email = null;
    _role = null;
    _profileImageUrl = null;
    notifyListeners();
  }

  // Update name
  void updateName(String userName) {
    _name = userName;
    notifyListeners();
  }

  // Update profile image URL
  void updateProfileImage(String? profileImageUrl) {
    _profileImageUrl = profileImageUrl;
    notifyListeners();
  }

  // Set or update role
  void updateRole(String? role) {
    _role = role;
    notifyListeners();
  }

  // Deprecated method (kept for compatibility if used elsewhere)
  void setRole(String? role) {
    _role = role;
    notifyListeners();
  }
}
