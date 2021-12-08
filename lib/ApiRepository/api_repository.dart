/*This class file consists of calls to API Endpoints*/
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nuniyoekyc/globals.dart' as globals;
import 'package:http_parser/http_parser.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

class ApiRepository {

  var headers = {
    'Content-Type': 'application/json'
  };

  //BASE URL : When Run In Android Emulators
  //final String BASE_API_URL = 'https://10.0.2.2:5001';

  //BASE URL : When Run In Web
  String API_TOKEN = "";

  final String BASE_WEB_URL = 'http://localhost:44330';

  final String BASE_API_LINK_URL = 'https://mkyc.mangalkeshav.com';


  final String BASE_ANDROID_EMULATOR_URL = "https://10.0.2.2:44330";

  //Shared Preference Methods

  SharedPreferences? preferences;

  Future<void> SetMobileOTP(String otp) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("MOBILE_OTP",otp);
    print("Your OTP is :"+prefs.getString("MOBILE_OTP"));
  }

  Future<void> SetStageId(String stage_id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STAGE_KEY,stage_id);
    print("Your Stage id :"+prefs.getString(STAGE_KEY));
  }

  Future<void> SetJwtToken(String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(JWT_TOKEN_KEY,token);
    print("Your JWT is :"+prefs.getString(JWT_TOKEN_KEY));
  }

  Future<String> GetCurrentJWTToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt_token= prefs.getString(JWT_TOKEN_KEY);
    print("JWT STORED INSIDE SHARED PREFERENCES :" + jwt_token);
    return jwt_token;
  }

  Future<String> Get_ESIGN_DOC_ID() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String docId= prefs.getString(DOC_ID_ESIGN_KEY);
    print("DOC ID STORED INSIDE SHARED PREFERENCES :" + docId);
    return docId;
  }

  Future<void> Set_ESIGN_DOC_ID(String docID) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(DOC_ID_ESIGN_KEY,docID);
    print("Your DOC ID is :"+prefs.getString(DOC_ID_ESIGN_KEY));
  }

  Future<String> Get_Bank_IFSC_CODE() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ifscCode= prefs.getString(BANK_IFSC_CODE_KEY);
    print("BANK_IFSC_CODE_KEY STORED INSIDE SHARED PREFERENCES :" + BANK_IFSC_CODE_KEY);
    return ifscCode;
  }

  Future<void> SET_BANK_IFSC_CODE(String ifscCode) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(BANK_IFSC_CODE_KEY,ifscCode);
    print("Your DOC ID is :"+prefs.getString(BANK_IFSC_CODE_KEY));
  }

  Future<String> GetLeadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lead_id= prefs.getString(LEAD_ID_KEY);
    print(lead_id);
    print("LEAD ID STORED INSIDE SHARED PREFERENCES :" + lead_id);
    return lead_id;
  }

  Future<String> GetMobileNumber() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mobile_no= prefs.getString(MOBILE_NUMBER_KEY);
    print("LEAD ID STORED INSIDE SHARED PREFERENCES :" + mobile_no);
    return mobile_no;
  }

  Future<void> UpdateStage_Id() async{

    String jwt_token= await GetCurrentJWTToken();
    print("Calling UpdateStage_Id Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Get UpdateStage_Id for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/lead/Update_StageId'));
    request.body = json.encode({
      "method_Name": "Update_Stage_Id",
      "org_Id": ORG_ID,
      "lead_Id": "$lead_id"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print("RESULT ID : "+result_Id.toString());
      String stage_id = valueMap["res_Output"][0]["stage_Id"];
      await SetStageId(stage_id);
    }
    else {
      print(response.reasonPhrase);
    }
  }



  ///API METHODS


  Future<bool> IPV_Video_Upload(List<int> byteFormatOfFile) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling IPV_Video_Upload Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("IPV_Video_Upload for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request;
    request = http.MultipartRequest('POST', Uri.parse('$BASE_API_LINK_URL/api/in_person_verification/Video_Upload'));
    request.files.add(await http.MultipartFile.fromBytes('File', byteFormatOfFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "file_up"));
    request.fields.addAll({
      'Lead_Id': '$lead_id'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print("IPV VIDEO UPLOADED SUCCESSFULLY");
      return true;
    }
    else {
      print(response.reasonPhrase);
      print("IPV VIDEO NOT UPLOADED");
      return false;
    }
  }

  ///Verify Bank Details
  Future<bool> verifyBankAccountLocal(String accountNo,String ifscNo) async{

    String jwt_token= await GetCurrentJWTToken();
    print("Calling Penny Drop Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Get Penny Drop for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    print("IFSC CODE"+ifscNo);
    SET_BANK_IFSC_CODE(ifscNo);
    print("Account No"+accountNo);
    print("Calling Penny Drop Using");

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/bank/VerifyBankAccount'));
    request.body = json.encode({
      "org_Id": ORG_ID,
      "lead_Id": "$lead_id",
      "beneficiary_account_no": "$accountNo",
      "beneficiary_ifsc": "$ifscNo"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print("RESULT ID : "+result_Id.toString());
      if(result_Id==1){
        return true;
      }
      else{
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<String> getIFSCDetails(String ifscCode) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling IFSC DETAILS LOCAL Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Get IFSC DETAILS LOCAL for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/bank/GetIfscDetails'));
    request.body = json.encode({
      "ifsc": "$ifscCode"
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      //GET IFSC DATA HERE
      print(result);
      if(result=="\"Not Found\"" || result =="Not Found"){
        print("Error");
        return "Not Found";
      }
      else{
        return result;
      }
    }
    else {
      print(response.reasonPhrase);
      print("Error");
      return "Not Found";
    }
  }

  Future<String> isValidIFSC(String ifscCode) async{
    var request = http.Request('GET', Uri.parse('https://ifsc.razorpay.com/$ifscCode'));
    //var request = http.Request('GET', Uri.parse('https://ifsc.razorpay.com/BARB0DBGHTW'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      return result;
    }
    else {
      print(response.reasonPhrase);
      return "Not Found";
    }
  }

  Future<Map<dynamic,dynamic>> GetPersonalDetails() async{
    Map valueMap = Map();
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Get Personal Details Status Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Get Personal Details for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/personal/Get_Personal_Details?Lead_Id=$lead_id'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      return valueMap;
    }
    else {
      print(response.reasonPhrase);
      return valueMap;
    }
  }

  Future<bool> GetPanStatus(String panCardNumber,String dateOfBirth) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Get Pan Status Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Get Pan Status for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/cvlkra/Get_PanStatus'));
    request.body = json.encode({
      "pan_No": "$panCardNumber",
      "lead_Id": "$lead_id",
      "org_Id": ORG_ID,
      "dob": "$dateOfBirth"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];

      ///Save Pan Owner Name
      //String result_description = valueMap["res_Output"][0]["result_Description"];
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //print("PAN OWNER NAME :"+result_description);
      //prefs.setString("PAN_OWNER_NAME",result_description);

      print("STATUS : "+result_Id.toString());
      if(result_Id==1){
        return true;
      }
      else{
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }


  ///api/success/Welcome_Email
  Future<void> Welcome_Email() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Welcome_Email Using API"+jwt_token);

    String doc_id = await Get_ESIGN_DOC_ID();
    print("Calling Welcome_Email DOC ID for "+doc_id);

    String lead_id = await GetLeadId();
    print("Welcome_Email for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/success/Welcome_Email'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<Map> Get_User_Details() async{
    Map valueMap = {};
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Get_User_Details Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Get_User_Details for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/success/Get_User_Details'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      valueMap = jsonDecode(result);
      print(valueMap);
      print(result);

      String email_Id = valueMap["res_Output"][0]["email_Id"];
      String mobile_No = valueMap["res_Output"][0]["mobile_No"];
      String date_of_Birth = valueMap["res_Output"][0]["date_of_Birth"];
      String pan_No = valueMap["res_Output"][0]["pan_No"];
      String name = valueMap["res_Output"][0]["name"];

      return valueMap;
    }
    else {
      print(response.reasonPhrase);
      return valueMap;
    }
  }

  Future<String> Get_eSign_Document_Details() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Get_eSign_Document_Details Using API"+jwt_token);

    String doc_id = await Get_ESIGN_DOC_ID();
    print("Calling Get_eSign_Document_Details DOC ID for "+doc_id);

    String lead_id = await GetLeadId();
    print("Get_eSign_Document_Details for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/eSign/Get_eSign_Document_Details'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "document_id": "$doc_id"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      String esignStatusMessage = valueMap["res_Output"][0]["result_Extra_Key"];

      print("STATUS : "+result_Id.toString());
      if(result_Id>0){
        return "true";
      }
      else{
        return esignStatusMessage;
      }
    }
    else {
      print(response.reasonPhrase);
      return response.reasonPhrase.toString();
    }
  }

  Future<void> SolicitPANDetailsFetchALLKRALocal(String panCard,String dOB) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Solicit Pan Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Solicit Pan for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/cvlkra/SolicitPANDetailsFetchALLKRA'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "paN_NO": "$panCard",
      "org_Id": ORG_ID,
      "date_Of_birth": "$dOB"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<void> Generate_Lead_Pdf() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Generate_Lead_Pdf Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Generate_Lead_Pdf for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/eSign/Generate_Lead_Pdf_new'));
    request.body = json.encode({
      "lead_Id": "$lead_id"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<String> Digio_eSign_Document_Upload() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Digio_eSign_Document_Upload Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Digio_eSign_Document_Upload for Lead ID : "+lead_id);

    String mobile_no = await GetMobileNumber();
    print("Digio_eSign_Document_Upload for Mobile Number : "+mobile_no);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/eSign/Digio_eSign_Document_Upload'));
    request.body = json.encode({
      //"mobile_No": "$mobile_no",
      "lead_Id": "$lead_id"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      //print("Your OTP IS VERIFIED OR NOT DEPENDS ON "+result_Id.toString());
      String docId = valueMap["res_Output"][0]["result_Description"];
      Set_ESIGN_DOC_ID(docId);
      return docId;
    }
    else {
      print(response.reasonPhrase);
      //return "";
      print("DUMMY DOC ID");
      Set_ESIGN_DOC_ID("DID211026152742428GVA27ENECZJJWT");
      return "DID211026152742428GVA27ENECZJJWT";
    }
  }



  Future<Uint8List?> Download_Application_Pdf() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Download_Application_Pdf Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Download_Application_Pdf for Lead ID : "+lead_id);

    String doc_id = await Get_ESIGN_DOC_ID();
    print("Download_Application_Pdf for Doc Id : "+doc_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/eSign/Download_Application_Pdf'));
    request.body = json.encode({
      "lead_Id": "$lead_id"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Uint8List byteFormatOfPdf = await response.stream.toBytes();
      print(byteFormatOfPdf);
      return byteFormatOfPdf;
    }
    else {
      print(response.reasonPhrase);
      return null;
    }
  }

  Future<File?> Digio_eSign_Document_Download() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Digio_eSign_Document_Download Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Digio_eSign_Document_Download for Lead ID : "+lead_id);

    String doc_id = await Get_ESIGN_DOC_ID();
    print("Digio_eSign_Document_Download for Doc Id : "+doc_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/eSign/Digio_eSign_Document_Download'));
    request.body = json.encode({
      "document_id": "$doc_id",
      "lead_Id": "$lead_id"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      print(result);
      String fileName = "pdfsasas";
      //final dir = await getExternalStorageDirectory();
      //final file = File("${dir!.path}/$fileName.pdf");
      //await file.writeAsBytes(result as Uint8List);
      return null;
    }
    else {
      print(response.reasonPhrase);
      var result = "";
      String fileName = "pdfsasas";
      final dir = await getExternalStorageDirectory();
      final file = File("${dir!.path}/$fileName.pdf");
      await file.writeAsBytes(result as Uint8List);
      return null;
    }
  }

  Future<void> InsertUpdateKYCRecordLocal() async{}

  Future<void> GenerateCodeChallengeLocal() async{}

  Future<void> VerifyDigiLockerAccountLocal() async{}

  Future<Map> DocumentUploadCheck() async{
    Map valueMap = {};
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Document Upload Check Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Document Upload Check for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/documentupload/Document_Upload_Check'));
    request.body = json.encode({
      "lead_Id": "$lead_id"
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print("Document Upload Check ka Response");
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      return valueMap;
    }
    else {
      print(response.reasonPhrase);
      return valueMap;
    }
  }

  Future<String> Document_Upload_FNO_Commodity(List<int> byteFormatOfFile,String fileName) async{

    String jwt_token= await GetCurrentJWTToken();
    print("Calling document_Upload_FNO_Commodity Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("document_Upload_FNO_Commodity for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request;
    request = http.MultipartRequest('POST', Uri.parse('$BASE_API_LINK_URL/api/documentupload/Document_Upload_FNO_Commodity'));
    request.files.add(await http.MultipartFile.fromBytes('File', byteFormatOfFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "$fileName"));
    request.fields.addAll({
      'Lead_Id': '$lead_id',
      'Document_name':'$fileName',
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print("Yeh FNO Upload Ka Response Aayaa hai");
      print(result);
      if(result==""){
        return "true";
      }
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print(result_Id);
      if(result_Id==1){
        return "true";
      }
      else{
        return "false";
      }
    }
    else {
      print(response.reasonPhrase);
      return response.reasonPhrase.toString();
    }
  }

  Future<String> DocumentUploadPAN(List<int> byteFormatOfFile,String fileExtension) async{

    String jwt_token= await GetCurrentJWTToken();
    print("Calling DocumentUploadPANLocal Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("DocumentUploadPANLocal for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request;
    request = http.MultipartRequest('POST', Uri.parse('$BASE_API_LINK_URL/api/documentupload/Document_Upload_PAN'));
    request.files.add(await http.MultipartFile.fromBytes('File', byteFormatOfFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "$fileExtension"));
    request.fields.addAll({
      'Lead_Id': '$lead_id'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print("Yeh Pan Upload Ka Response Aayaa hai");
      print(result);
      if(result==""){
        return "true";
      }
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print(result_Id);
      if(result_Id==1){
        return "true";
      }
      else{
        return "false";
      }
    }
    else {
      print(response.reasonPhrase);
      return response.reasonPhrase.toString();
    }
  }

  Future<String> DocumentUploadDigitalSignature(List<int> byteFormatOfFile,String fileExtension) async{

    String jwt_token= await GetCurrentJWTToken();
    print("Calling DocumentUploadDigitalSignature Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("DocumentUploadDigitalSignature for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request;
    request = http.MultipartRequest('POST', Uri.parse('$BASE_API_LINK_URL/api/documentupload/Document_Upload_Signature'));
    request.files.add(await http.MultipartFile.fromBytes('File', byteFormatOfFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "$fileExtension"));
    request.fields.addAll({
      'Lead_Id': '$lead_id'
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return "true";
    }
    else {
      print(response.reasonPhrase);
      return response.reasonPhrase.toString();
    }
  }

  Future<bool>Email_Status(String emailID) async{

    String jwt_token= await GetCurrentJWTToken();
    print("Calling Email Status Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Email Status for Lead ID : "+lead_id.toString());

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/email/Email_Status'));
    request.body = json.encode({
      "org_Id": ORG_ID,
      "lead_Id": "$lead_id",
      "email": "$emailID",
      "method_Name": "Email_Status"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int status = valueMap["status"];
      print("STATUS : "+status.toString());
      if(status==200){
        return true;
      }
      else{
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<bool> UpdateEmail(String emailId) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Update Email Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Update Email Status for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/email/Update_Email'));
    request.body = json.encode({
      "org_Id": ORG_ID,
      "lead_Id": "$lead_id",
      "email": "$emailId",
      "method_Name": "Update_Email"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print(result_Id);
      if(result_Id==1){
        return true;
      }
      else{
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<Map<dynamic,dynamic>> IFSCMasterSearchLocal(String branchName , String branchLocation) async{
    Map valueMap = Map();
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Update IFSC SEARCH Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("IFSC Search for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/ifscmaster/IFSC_Master_Search'));
    request.body = json.encode({
      "bank": "$branchName",
      "ifsc": "string",
      "branch": "$branchLocation"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      return valueMap;
    }
    else {
      print(response.reasonPhrase);
      return valueMap;
    }

  }

  Future<String> IPVOTP() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling IPVOTP LOCAL Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("IPVOTP LOCAL for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/in_person_verification/IPV_OTP'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "method_Name": "Generate_OTP",
      "org_Id": ORG_ID,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      return result;
    }
    else {
      print(response.reasonPhrase);
      return "Internal Server Error";
    }
  }

  Future<bool> VerifyIPVOTP(String otp) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Verify IPV OTP LOCAL Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Verify IPV OTP LOCAL for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/in_person_verification/Verify_IPV_OTP'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "otp": "$otp",
      "org_Id": "$ORG_ID",
      "method_Name": "Verify_IPV_OTP"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
      Map valueMap = jsonDecode(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];

      if(result_Id == 1){
        return true;
      }
      else{
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<void> Video_Upload(List<int> byteFormatOfFile,String fileExtension) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling SaveIPVVideo Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("SaveIPVVideo for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request;
    request = http.MultipartRequest('POST', Uri.parse('$BASE_API_LINK_URL/api/in_person_verification/Video_Upload'));
    request.files.add(await http.MultipartFile.fromBytes('File', byteFormatOfFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "$fileExtension"));
    request.fields.addAll({
      'Lead_Id': '$lead_id'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<void> VIPV_Selfie_Upload(List<int> byteFormatOfFile,String fileExtension) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling SaveIPVVideo Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("VIPV_Selfie_Upload for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request;
    request = http.MultipartRequest('POST', Uri.parse('$BASE_API_LINK_URL/api/in_person_verification/VIPV_Selfie_Upload'));
    request.files.add(await http.MultipartFile.fromBytes('File', byteFormatOfFile,
        contentType: new MediaType('application', 'octet-stream'),
        filename: "$fileExtension"));
    request.fields.addAll({
      'Lead_Id': '$lead_id'
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<bool> Digio_PanAuthentication(String panNumber,String dob) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Digio_PanAuthentication LOCAL Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Digio_PanAuthentication for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/PanAuthentication/Digio_PanAuthentication'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "id_no": "$panNumber",
      "dob": "$dob"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      String panOwnerName = valueMap["res_Output"][0]["stage_Id"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("PAN OWNER NAME :"+panOwnerName);
      prefs.setString("PAN_OWNER_NAME",panOwnerName);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      //String result_Description=valueMap["res_Output"][0]["result_Description"];
      print("PAADJNJKADB"+result_Id.toString());
      if(result_Id>0){
        print("Returning True");
        return true;
      }
      else{
        print("Returning False");
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<bool> ReadLead(String mobileNo) async{
    print("Starts Boley");
    var headers = {
      "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        // Required for cookies, authorization headers with HTTPS
      //"Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      'Content-Type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/lead/Read_Lead'));
    request.body = json.encode({
      "mobile_No": "$mobileNo",
      "method_Name": "Check_Mobile_No",
      "org_Id": ORG_ID,
      "flow_Id": FLOW_ID,
      "current_Stage_Id": CURRENT_STAGE_ID
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print(result_Id);
      String lead_id = valueMap["res_Output"][0]["lead_Id"];
      print(lead_id);
      await StoreLocal().StoreLeadIdToLocalStorage(lead_id);
      String savedLead = await StoreLocal().getLeadIdFromLocalStorage();
      print("LEAD ID SAVED LOCALLY IS :"+savedLead);

      String otp = valueMap["res_Output"][0]["stage_Id"];
      await SetMobileOTP(otp);

      if(result_Id == 1){
        return true;
      }
      return false;
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<bool> VerifyOTP(String mobileNumber,String userEnteredOTP) async{
    var headers = {
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/lead/Verify_OTP'));
    request.body = json.encode({
      "mobile_No": "$mobileNumber",
      "otp": "$userEnteredOTP",
      "method_Name": "Check_OTP",
      "org_Id": ORG_ID,
      "flow_Id": FLOW_ID,
      "current_Stage_Id": CURRENT_STAGE_ID
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      print(result);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      //print("Your OTP IS VERIFIED OR NOT DEPENDS ON "+result_Id.toString());
      String jwt_token = valueMap["res_Output"][0]["result_Description"];
      await SetJwtToken(jwt_token);
      String stage_id = valueMap["res_Output"][0]["stage_Id"];
      await SetStageId(stage_id);
      if(result_Id==1){
        return true;
      }
      else{
        return false;
      }
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<void> LeadLocation(String phoneNumber,String ipAddress,String city,String country,String state,String latitude,String longitude) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling LeadLocation  Using API KEY "+jwt_token);

    String lead_id = await GetLeadId();
    print("LeadLocation for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/lead/Lead_Location'));
    request.body = json.encode({
      "mobile_No": phoneNumber,
      "ip": ipAddress,
      "city": city,
      "country": country,
      "state": state,
      "latitude": latitude,
      "longitude": longitude,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<bool> NSDLeKYCPanAuthenticationLocal(String panCardNumber) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling NSDL EKYC PAN Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("NSDL EKYC PAN for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/nsdlpan/NSDLeKYCPanAuthentication'));
    request.body = json.encode({
      "pan_No": "$panCardNumber",
      "lead_Id": "$lead_id",
      "org_Id": ORG_ID,
      "method_Name": "NSDLeKYCPanAuthentication"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      return true;
    }
    else {
      print(response.reasonPhrase);
      return false;
    }
  }

  Future<void> PanAuthenticationLocal() async{}

  Future<bool> PersonalDetailsLocal(String fatherName,String motherName,String income,String gender,String maritalStatus,String politicallyExposed,String occupation,String tradingExperience) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling PERSONAL DETAILS  Using API KEY "+jwt_token);

    String lead_id = await GetLeadId();
    print("PERSONAL DETAILS for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/personal/Personal_Details'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "org_Id": globals.ORG_ID,
      "father_Name": "$fatherName",
      "mother_Name": "$motherName",
      "income": "$income",
      "gender": "$gender",
      "marital_Status": "$maritalStatus",
      "politically_Exposed": "$politicallyExposed",
      "occupation": "$occupation",
      "trading_Experience": "$tradingExperience",
      "education": "string"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      int result_Id = valueMap["res_Output"][0]["result_Id"];
      print(result_Id);
      String stage_id = valueMap["res_Output"][0]["stage_Id"];
      await SetStageId(stage_id);
      if(result_Id == 1){
        return true;
      }
      return false;
    }
    else {
      print(response.reasonPhrase);
      return false;
    }

  }

  Future<String> GetAuthorizationCode(String hmac,String code,String state) async{
    //String jwt_token= await GetCurrentJWTToken();
    //print("Calling NSDL EKYC PAN Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Authorization Token for Lead ID : "+lead_id);

    /*var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };*/

    var headers = {
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/digilocker/GetAuthorizationCode'));
    request.body = json.encode({
      "Lead_Id": "$lead_id",
      "hmac": "$hmac",
      "source":1,
      "code": "$code",
      "Method_Name": 'DigiLocker_Res',
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print("DEKH CHOTE YEH VALUE HAI");
      print(valueMap);
      String result_description = valueMap["res_Output"];
      print("Aur tera Address hai :- "+result_description);
      return result_description;
    }
    else {
      print(response.reasonPhrase);
      return "Error";
    }
  }

  Future<String?> RazorPayment_MarketSegment(int planID) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling RazorPayment_MarketSegment  Using API KEY "+jwt_token);

    String lead_id = await GetLeadId();
    print("RazorPayment_MarketSegment for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/razorpay/MarketSegmnent'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "org_Id": globals.ORG_ID,
      "segment": "equity",
      "plan_ID": planID
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      String orderID = valueMap["res_Output"][0]["result_Extra_Key"];
      print("Your Razor Pay Order Id is : "+orderID);
      return orderID;
    }
    else {
      print(response.reasonPhrase);
      return null;
    }
  }

  // RazorPayment Status New
  Future<void> RazorPaymentStatus(String amountPayed,String merchantID ,String paymentID,String signature) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling RazorPaymentStatus  Using API KEY "+jwt_token);

    String lead_id = await GetLeadId();
    print("RazorPaymentStatus for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/razorpay/RazorPaymentStatus'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
      "org_Id": globals.ORG_ID,
      "amount": 200,
      "currencyType": "INR",
      "merchantTransactionId": "$merchantID",
      "payment_Id": "$paymentID",
      "signature": "$signature"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);

    }
    else {
      print(response.reasonPhrase);
      //return false;
    }

  }

  Future<void> ConfirmIFSCDetails(String result) async {
    Map valueMap = jsonDecode(result);
    String _ifscCodeR = valueMap["IFSC"];
    String _bankNameR = valueMap["BANK"];
    String district = valueMap["DISTRICT"];
    String city = valueMap["CITY"];
    String state = valueMap["STATE"];
    String _branchNameR = valueMap["BRANCH"];
    String _addressR = valueMap["ADDRESS"];

    String jwt_token= await GetCurrentJWTToken();
    print("Calling ConfirmIFSCDetails  Using API KEY "+jwt_token);

    String lead_id = await GetLeadId();
    print("ConfirmIFSCDetails for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };


    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/bank/ConfirmIfscDetails'));
    request.body = json.encode({
      "org_Id": globals.ORG_ID,
      "lead_Id": "$lead_id",
      "ifsC_Code": "$_ifscCodeR",
      "method_Name": "",
      "micr": "",
      "address": "$_addressR",
      "branch": "$_branchNameR",
      "contact": "",
      "phone": "",
      "city": "$city",
      "state": "$state",
      "district": "$district",
      "bank": "$_bankNameR"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Map valueMap = jsonDecode(result);
      print(valueMap);
      //int result_Id = valueMap["res_Output"][0]["result_Id"];
      //print(result_Id);
      //String stage_id = valueMap["res_Output"][0]["stage_Id"];
      //await SetStageId(stage_id);
      //if(result_Id == 1){
        //return true;
      //}
      //return false;
    }
    else {
      print(response.reasonPhrase);
      //return false;
    }
  }

  Future<void> RazorPayStatusLocal(int amountPayed,String currency , String mobileNumber, String merchantTransactionID) async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling RAZOR PAY STATUS Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("RAZOR PAY STATUS for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('$BASE_API_LINK_URL/api/razorpay/RazorPayStatus'));
    request.body = '''{\r\n  "inr": $amountPayed,\r\n  "currency": "$currency",\r\n  "mobile_No": "$mobileNumber",\r\n  "merchantTransactionId": "$merchantTransactionID"\r\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future<void> Create_Aadhaar_From_XML() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Create_Aadhaar_From_XML Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Create_Aadhaar_From_XML for Lead ID : "+lead_id);

    var headers = {
      'Authorization': 'Bearer $jwt_token',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('$BASE_API_LINK_URL/api/documentupload/Create_Aadhaar_From_XML'));
    request.body = json.encode({
      "lead_Id": "$lead_id",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print(result);
    }
    else {
      print(response.reasonPhrase);
    }
  }

}