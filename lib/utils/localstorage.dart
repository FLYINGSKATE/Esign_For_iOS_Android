import 'package:shared_preferences/shared_preferences.dart';

class StoreLocal{

  final String mobileNumberKey = "MOBILE_NUMBER";
  final String emailIdKey = "EMAIL_ID";
  final String panNumberKey = "PAN_NUMBER";
  final String bankNumberKey  = "BANK_AC_NUMBER";
  final String fatherNameKey  = "FATHER_NAME";
  final String motherNameKey  = "MOTHER_NAME";
  final String routeNameKey = "ROUTE_NAME";
  final String leadIDKey = "LEAD_ID";
  final String stageKey = "STAGE_ID";

  /////PHONE NUMBER
  Future<void> StorePhoneNumberToLocalStorage(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(mobileNumberKey,mobileNumber);
  }

  Future<String?> getPhoneNumberFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString(mobileNumberKey);
    return phoneNumber;
  }

  ////LEAD ID
  Future<void> StoreLeadIdToLocalStorage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(leadIDKey,value);
  }

  Future<String?> getLeadIdFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(leadIDKey);
    return value;
  }

  /////EMAIL ID
  Future<void> StoreEmailIdToLocalStorage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(emailIdKey,value);
  }

  Future<String?> getEmailIdFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(emailIdKey);
    return value;
  }

  /////PAN Number
  Future<void> StorePANNumberToLocalStorage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(panNumberKey,value);
  }

  Future<String?> getPANNumberFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(panNumberKey);
    return value;
  }


  ///FATHER NAME
  Future<void> StoreFatherNameToLocalStorage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(fatherNameKey,value);
  }

  Future<String?> getFatherNameFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(fatherNameKey);
    return value;
  }


  ///MOTHER NAME
  Future<void> StoreMotherNameToLocalStorage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(motherNameKey,value);
  }

  Future<String?> getMotherNameFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(motherNameKey);
    return value;
  }


  ///ROUTE NAME
  Future<void> StoreRouteNameToLocalStorage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(routeNameKey,value);
  }

  Future<String?> getRouteNameFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(routeNameKey);
    return value;
  }

  Future<void> StoreStageIdToLocalStorage(String stageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(stageKey,stageId);
  }

  Future<String?> getStageIdFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString(stageKey);
    return phoneNumber;
  }
}