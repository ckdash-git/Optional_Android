import 'package:flutter/foundation.dart';

class UserProfile {
  String name;
  String email;

  UserProfile({required this.name, required this.email});
}

class UserProfileProvider with ChangeNotifier {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  void updateProfile({required String name, required String email}) {
    _profile = UserProfile(name: name, email: email);
    notifyListeners();
  }
}
