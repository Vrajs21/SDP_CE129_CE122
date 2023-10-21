import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:canteen_food_ordering_app/models/user.dart' as app_user;

class AuthNotifier extends ChangeNotifier {
  User? _user;

  User? get user {
    return _user;
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Test
  app_user.User? _userDetails;

  app_user.User? get userDetails => _userDetails;

  setUserDetails(app_user.User user) {
    _userDetails = user;
    notifyListeners();
  }
}
