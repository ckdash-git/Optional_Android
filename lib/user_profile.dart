import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProfile {
  String fullName;
  String email;

  UserProfile({required this.fullName, required this.email});
}

class UserProfileProvider extends ChangeNotifier {
  late  UserProfile _profile;

  UserProfileProvider({FirebaseAuth? firebaseAuth}) {
    final auth = firebaseAuth ?? FirebaseAuth.instance;
    _profile = UserProfile(
      fullName: auth.currentUser?.displayName ?? "Chandan",
      email: auth.currentUser?.email ?? "",
    );
  }

  UserProfile get profile => _profile;

  void updateProfile({String? fullName, String? email}) {
    if (fullName != null) _profile.fullName = fullName;
    if (email != null) _profile.email = email;
    notifyListeners();
  }
  void clearProfile() {
  _profile = UserProfile(fullName: "", email: "");
    notifyListeners();
  }
}
