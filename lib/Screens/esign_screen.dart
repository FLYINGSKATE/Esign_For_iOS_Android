///Static Page

import 'dart:io';

import 'package:esign/ApiRepository/api_repository.dart';
import 'package:esign/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';


import '../globals.dart';


class EsignScreen extends StatefulWidget {
  const EsignScreen({Key? key}) : super(key: key);

  @override
  _EsignScreenState createState() => _EsignScreenState();
}

class _EsignScreenState extends State<EsignScreen> {


  String PHONE_NUMBER = "";


  ///
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String waitMessageOnButton = 'Please Wait...';
  String messageOnButton = 'eSign';

  String cityname = "Mumbai";
  String panOwnerName = "";

  String docID = "dummy";

  String messageFromEsign = "eSign is an online electronic signature service that can facilitate an Aadhaar holder to digitally sign a document after an OTP authentication thus requiring no paper based application form for account opening purposes. We provide the eSign service using NSDL e-Gov (licensed CA) and the authentication of the signer will be carried out by the e-KYC services of UIDAI and on successful authentication i.e., on receiving the consent from the signer, electronic signature on the account opening form will be ascribed by eSign services of NSDL e-Gov.";

  bool hideEsignContent = false;
  ///

  @override
  void initState() {
    super.initState();
    //manageSteps();
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
      body: hideEsignContent?Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "Please Wait ....",textAlign:TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
            ),
            SizedBox(height: 20,),
            CircularProgressIndicator(color: primaryColorOfApp,),
          ],
        ),
      ):SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
              padding: const EdgeInsets.all(30.0),
              child:Column(
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
                  Text("$messageFromEsign",style: GoogleFonts.openSans(
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
                        await DoEsign();
                        //Navigator.pushNamed(context, 'UCC');
                      },
                      color: primaryColorOfApp,
                      child: docID==""?Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "$waitMessageOnButton",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                          ),
                          SizedBox(width:20,),
                          CircularProgressIndicator(color: Colors.white,),
                        ],
                      ):Text(
                          "$messageOnButton",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Divider(thickness: 2.0,),
                  SizedBox(height: 20,),
                ],
              )
          ),
        ),
      ),)
    );
  }


  Future<void> DoEsign() async {
    print("CHECKING FOR ESIGN RESPONSE");
    //Fluttertoast.showToast(msg: "CHECKING FOR ESIGN RESPONSE", toastLength: Toast.LENGTH_SHORT);
    //get doc id from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!await prefs.containsKey(DOC_ID_ESIGN_KEY)){
      print("DOC ID DOESN'T EXISTS");
      print("DOING ESIGN FOR THE FIRST TIME");
      docID = "";
      waitMessageOnButton = "Generating PDF...";
      setState(() {});
      await GeneratePDFAndGetEsignDocID();
      await callPlatformSpecificEsignSDKs();
      return;
    }

    //String docID = prefs.getString(globa);
    String EsignStatus = await ApiRepository().Get_eSign_Document_Details();
    if(EsignStatus =="true"){
      print("CONGRATS YOU HAVE DONE ESIGN SUCCESSFULLY");
      //Updating Stage ID Now because we don't got time on Android Native to update it
      //await ApiRepository().UpdateStage_Id();
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //String ThisStepId = prefs.getString(STAGE_KEY);
      //print("YOUR NEW STAGE ID IS"+ThisStepId);
      //Navigator.pushReplacementNamed(context,ThisStepId);
    }
    else{
      print("OOPS ! eSIGN HASN'T been successful for doc id : "+docID);
      messageFromEsign = "Error : ";
      messageFromEsign += EsignStatus;
      messageFromEsign += "\nPlease Contact Support (9967413567) / Mail to : kyc@mangalkeshav.com ";
      hideEsignContent = false;
      setState(() {});
      //Navigator.pushReplacementNamed(context, "ESign");
    }
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
      Fluttertoast.showToast(msg: "Cannot Find Doc ID from server", toastLength: Toast.LENGTH_SHORT);
    }
  }

  

  Future<void> callPlatformSpecificEsignSDKs() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(PHONE_NUMBER.isEmpty){
      String phoneNumber = await prefs.getString(MOBILE_NUMBER_KEY);
      PHONE_NUMBER = phoneNumber;
    }

    await prefs.setString(DOC_ID_ESIGN_KEY,docID);
    messageOnButton = "Proceed";
    setState(() {});

    if(Platform.isAndroid){
      try {
        await platform.invokeMethod('esignThisDocument',{"docID":docID,"phoneNumber":PHONE_NUMBER});
        //print("We got this result from Android"+result.toString());
        //SHOW TOAST
      } on PlatformException catch (e) {
        //SHOW TOAST
        Fluttertoast.showToast(msg: "Failed to Open Digio SDK :"+e.message.toString(), toastLength: Toast.LENGTH_SHORT);
      }
    }
    if(Platform.isIOS){
      try {
        //Fluttertoast.showToast(msg: "Chalo IOS MIEN", toastLength: Toast.LENGTH_SHORT);
        await platform.invokeMethod('doEsign' ,{"docId": docID,"phoneNumber":PHONE_NUMBER}).whenComplete(() { Navigator.pushNamed(context, "EsignResponse");print("OUT OF IOS");});
        //Navigator.pushNamed(context, "EsignResponse");

      } on PlatformException catch (e) {
        Fluttertoast.showToast(msg: "Failed to Open Digio Framework :"+e.message.toString(), toastLength: Toast.LENGTH_SHORT);
        print("Failed: '${e.message}'.");
      }
    }
    else{
      //do nothing SHOW TOAST HERE
      Fluttertoast.showToast(msg: "ONLY SUPPORTED FOR : ANDROID & IOS", toastLength: Toast.LENGTH_SHORT);
    }
  }

}
