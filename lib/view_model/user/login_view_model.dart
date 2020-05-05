import 'package:bondo/model/user.dart';
import 'package:bondo/repository/user_repository.dart' as userRepo;
import 'package:bondo/view_model/firebase_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_country_picker/country.dart';

class LoginViewModel extends ChangeNotifier implements FirebaseRequest {
  bool _isLoading = false;
  bool _isObscure = true;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isObscure => _isObscure;

  set isObscure(bool value) {
    _isObscure = value;
    notifyListeners();
  }

  login({email, password}) async {
    final result = await userRepo.login(email, password);
    if (result is bool && result) {
      onSuccess = true;
    } else {
      onSuccess = false;
      responseMessage = result;
    }
    _isLoading = false;
    notifyListeners();
  }

  @override
  bool onSuccess;

  @override
  String responseMessage = "None";
}
