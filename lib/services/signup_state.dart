import 'package:flutter/material.dart';

class SignupState extends ChangeNotifier {
  String name = '';
  String birthDate = '';
  String phoneNumber = '';
  String email = '';
  String password = '';
  String carNumber = '';
  bool marketingOptIn = false;

  bool get step1Filled => true; // 약관 체크는 step1 화면에서 직접 체크
  bool get step2Filled => name.isNotEmpty && birthDate.isNotEmpty && phoneNumber.isNotEmpty;
  bool get step3Filled => email.isNotEmpty && password.isNotEmpty;
  bool get step5Filled => carNumber.isNotEmpty;

  void updateStep1({required bool marketingOptIn}) {
    this.marketingOptIn = marketingOptIn;
    notifyListeners();
  }

  void updateStep2({required String name, required String birthDate, required String phoneNumber}) {
    this.name = name;
    this.birthDate = birthDate;
    this.phoneNumber = phoneNumber;
    notifyListeners();
  }

  void updateStep3({required String email, required String password}) {
    this.email = email;
    this.password = password;
    notifyListeners();
  }

  void updateStep5({required String carNumber}) {
    this.carNumber = carNumber;
    notifyListeners();
  }

  void updateMarketingOptIn(bool value) {
    marketingOptIn = value;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth_date': birthDate,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
      'car_number': carNumber,
      'marketing_opt_in': marketingOptIn,
    };
  }

  void clear() {
    name = '';
    birthDate = '';
    phoneNumber = '';
    email = '';
    password = '';
    carNumber = '';
    marketingOptIn = false;
    notifyListeners();
  }
}