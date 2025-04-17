import 'package:flutter/foundation.dart';

class UserProfile {
  String name;
  String email;

  UserProfile({required this.name, required this.email});
}

class UserProfileProvider extends ChangeNotifier {
  final UserProfile _profile = UserProfile(
    name: "Chandan Kumar Dash",
    email: "chandan@email.com",
  );

  UserProfile get profile => _profile;

  void updateProfile({String? name, String? email}) {
    if (name != null) _profile.name = name;
    if (email != null) _profile.email = email;
    notifyListeners();
  }
}
