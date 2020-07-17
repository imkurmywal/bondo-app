import 'package:bondo/model/user.dart';
import 'package:bondo/repository/user_repository.dart' as userRepo;
import 'package:bondo/view_model/firebase_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_country_picker/country.dart';

class SignUpViewModel extends ChangeNotifier implements FirebaseRequest {
  bool _isLoading = false;
  bool _isObscure = true;
  Country _country = Country.US;

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

  Country get country => _country;

  set country(Country value) {
    _country = value;
    notifyListeners();
  }

  createUser({user, password}) async {
    final result = await userRepo.register(user, password);
    if (result is bool && result) {
      onSuccess = true;
      _isLoading = false;
      notifyListeners();
    } else {
      onSuccess = false;
      responseMessage = result;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isEmailAlreadyExist({String email}) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1;
  }

  @override
  bool onSuccess;

  @override
  String responseMessage = "None";
}
