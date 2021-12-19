/*This class file consists of calls to API Endpoints*/
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';


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

  final String BASE_API_LINK_URL = 'YOUR_BASE_URL_HERE';


  //Shared Preference Methods

  SharedPreferences? preferences;

  Future<void> SetJwtToken(String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(JWT_TOKEN_KEY,token);
    print("Your JWT is :"+token);
  }

  Future<String> GetCurrentJWTToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt_token= prefs.getString(JWT_TOKEN_KEY);
    print("JWT STORED INSIDE SHARED PREFERENCES :" + jwt_token!);
    return jwt_token;
  }

  Future<String> GetLeadId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lead_id= prefs.getString(LEAD_ID_KEY);
    print(lead_id);
    print("LEAD ID STORED INSIDE SHARED PREFERENCES :" + lead_id!);
    return lead_id;
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

  Future<String?> Get_ESIGN_DOC_ID() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? docId= prefs.getString(DOC_ID_ESIGN_KEY);
    print("DOC ID STORED INSIDE SHARED PREFERENCES :" + docId!);
    return docId;
  }

  Future<void> Set_ESIGN_DOC_ID(String docID) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(DOC_ID_ESIGN_KEY,docID);
    print("Your DOC ID is :"+docID);
  }

  Future<String?> GetMobileNumber() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobile_no= prefs.getString(MOBILE_NUMBER_KEY);
    print("LEAD ID STORED INSIDE SHARED PREFERENCES :" + mobile_no!);
    return mobile_no;
  }

  ///DUMMY API METHODS - PLACE YOUR OWN METHODS
  Future<String> Get_eSign_Document_Details() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Get_eSign_Document_Details Using API"+jwt_token);

    String? doc_id = await Get_ESIGN_DOC_ID();
    print("Calling Get_eSign_Document_Details DOC ID for "+doc_id!);

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

  Future<String> Digio_eSign_Document_Upload() async{
    String jwt_token= await GetCurrentJWTToken();
    print("Calling Digio_eSign_Document_Upload Using API"+jwt_token);

    String lead_id = await GetLeadId();
    print("Digio_eSign_Document_Upload for Lead ID : "+lead_id);

    String? mobile_no = await GetMobileNumber();
    print("Digio_eSign_Document_Upload for Mobile Number : "+mobile_no!);

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

    String? doc_id = await Get_ESIGN_DOC_ID();
    print("Download_Application_Pdf for Doc Id : "+doc_id!);

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

    String? doc_id = await Get_ESIGN_DOC_ID();
    print("Digio_eSign_Document_Download for Doc Id : "+doc_id!);

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


}