import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProfile {
  String fullName;
  String email;

  UserProfile({required this.fullName, required this.email});
}

class UserProfileProvider extends ChangeNotifier {
  final UserProfile _profile = UserProfile(
    fullName: FirebaseAuth.instance.currentUser?.displayName ?? "Chandan",
    email: FirebaseAuth.instance.currentUser?.email ?? "",
  );

  UserProfile get profile => _profile;

  void updateProfile({String? fullName, String? email}) {
    if (fullName != null) _profile.fullName = fullName;
    if (email != null) _profile.email = email;
    notifyListeners();
  }
}
