///Static Page

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';


class EsignScreen extends StatefulWidget {
  const EsignScreen({Key? key}) : super(key: key);

  @override
  _EsignScreenState createState() => _EsignScreenState();
}

class _EsignScreenState extends State<EsignScreen> {

  String PAN_NO = "";
  String GENDER = "";
  String DOB = "";
  String EMAIL_ID = "";
  String PHONE_NUMBER = "";
  String USER_NAME="";

  ///
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Battery Level';

  String cityname = "Mumbai";
  String panOwnerName = "";

  String docID = "";

  String messageFromApi = "eSign is an online electronic signature service that can facilitate an Aadhaar holder to digitally sign a document after an OTP authentication thus requiring no paper based application form for account opening purposes. We provide the eSign service using NSDL e-Gov (licensed CA) and the authentication of the signer will be carried out by the e-KYC services of UIDAI and on successful authentication i.e., on receiving the consent from the signer, electronic signature on the account opening form will be ascribed by eSign services of NSDL e-Gov.";
  ///

  @override
  void initState() {
    super.initState();
    //manageSteps();
    WidgetsBinding.instance!.addPostFrameCallback((_) => GeneratePDFAndGetEsignDocID());
    WidgetsBinding.instance!.addPostFrameCallback((_) => fetchDetails());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: _onWillPop, child:Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: WidgetHelper().NuniyoAppBar(),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().DetailsTitle('Last Step !'),
                Text("The last step is to digitally sign your application form(s).We will email you your login credentials once your forms are verified.",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 20,),
                Divider(thickness: 2.0,),
                SizedBox(height: 20,),
                Text("eSign",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 22,fontWeight: FontWeight.bold),
                ),),
                SizedBox(height: 20,),
                Text("$messageFromApi",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 20,),
                Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: FlatButton(
                    disabledTextColor: Colors.blue,
                    disabledColor: secondaryColorOfApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: docID==""?null:() async {
                      if (Platform. isAndroid) {
                        bool es = await startEsigning(docID);
                        //print("Esign :KAAAA"+es.toString());
                      } else if (Platform. isIOS) {
                        Fluttertoast.showToast(msg: "Oooo`! ios`! ", toastLength: Toast.LENGTH_SHORT);
                        await startEsigningForIOS(docID);
                      }
                      //Navigator.pushNamed(context, 'UCC');
                      },
                    color: primaryColorOfApp,
                    child: Text(docID==""?"Please Wait...Creating PDF":
                        "eSign",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Divider(thickness: 2.0,),
                SizedBox(height: 20,),
                ///Card Box
                Container(
                  height: 250.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: new BoxDecoration(
                    boxShadow: [ //background color of box
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
                      )
                    ],
                  ),
                  child: Container(
                    height: 80,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          ListTile(
                            minLeadingWidth: 0.0,
                            leading: Icon(Icons.person_outline_outlined),
                            title: Text("$USER_NAME",style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 14),
                            ),),
                          ),
                          Row(
                            children: [
                              SizedBox(width:15.0),
                              Icon(Icons.card_giftcard,color:Colors.grey),
                              SizedBox(width:14.0),
                              Text("$DOB",style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 14),
                              ),),
                              SizedBox(width: 40,),
                              Icon(Icons.male,color:Colors.grey),
                              SizedBox(width:15.0),
                              Text("$GENDER",style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 14),
                              ),),
                            ],
                          ),
                          ListTile(
                            minLeadingWidth: 0.0,
                            leading: Icon(Icons.email_outlined),
                            title: Text("$EMAIL_ID",style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 14),
                            ),),
                          ),
                          ListTile(
                            minLeadingWidth: 0.0,
                            leading: Icon(Icons.phone_android),
                            title: Text("$PHONE_NUMBER",style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 14),
                            ),),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
                      Text("Your PAN",style: GoogleFonts.openSans(
                        textStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, letterSpacing: .5,fontSize: 24),
                      ),),
                      SizedBox(height: 10,),
                      Text("$PAN_NO",style: GoogleFonts.openSans(
                        textStyle: TextStyle(color: Colors.black,letterSpacing: .5,fontSize: 20),
                      ),),
                      SizedBox(height: 10,),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),)
    );
  }


  Future<void> GeneratePDFAndGetEsignDocID() async{
    await ApiRepository().Generate_Lead_Pdf();
    //print("GETting Esign Doc ID");
    docID = await ApiRepository().Digio_eSign_Document_Upload();
    //print("Got Esign Doc ID");
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
      });
    });
    //print("After 1 second of Delay");

    if(docID==""){
      ///Do Something here to handle Error
    }
  }

  Future<void> fetchDetails() async {

    Map valueMap = await ApiRepository().Get_User_Details();

    EMAIL_ID = valueMap["res_Output"][0]["email_Id"];
    PHONE_NUMBER = valueMap["res_Output"][0]["mobile_No"];
    DOB = valueMap["res_Output"][0]["date_of_Birth"];
    PAN_NO = valueMap["res_Output"][0]["pan_No"];
    USER_NAME = valueMap["res_Output"][0]["name"];
    GENDER = valueMap["res_Output"][0]["gender"];

    /*DOB = prefs.getString(DATE_OF_BIRTH_KEY);
    EMAIL_ID =prefs.getString(EMAIL_ID_KEY);
    PAN_NO = prefs.getString(PAN_NO_KEY);
    cityname = prefs.getString("CITY");
    username = prefs.getString(MOBILE_NUMBER_KEY);
    panOwnerName = prefs.getString("PAN_OWNER_NAME");*/

    setState(() {});
  }

  Future<bool> startEsigning(String docID) async {
    bool result = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = await prefs.getString(MOBILE_NUMBER_KEY);

    try {
      result= await platform.invokeMethod('esignThisDocument',{"docID":docID,"phoneNumber":phoneNumber});
      //print("We got this result from Android"+result.toString());
      return result;
    } on PlatformException catch (e) {
      return false;
    }
  }

  Future<void> startEsigningForIOS(String docID) async{
    try {
      //Fluttertoast.showToast(msg: "Chalo IOS MIEN", toastLength: Toast.LENGTH_SHORT);
      await platform.invokeMethod('doEsign' ,{"docId": docID,"phoneNumber":PHONE_NUMBER});
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: "NahI HO PAAYA :"+e.message.toString(), toastLength: Toast.LENGTH_SHORT);
      print("Failed: '${e.message}'.");
    }
  }
}
