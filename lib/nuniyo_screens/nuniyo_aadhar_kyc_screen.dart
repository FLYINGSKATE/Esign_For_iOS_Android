//Aadhar KYC


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/globals.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'nuniyo_digilocker_web_view.dart';


class AadharKYCScreen extends StatefulWidget {
  const AadharKYCScreen({Key? key}) : super(key: key);

  @override
  _AadharKYCScreenState createState() => _AadharKYCScreenState();
}

class _AadharKYCScreenState extends State<AadharKYCScreen> {


  @override
  void initState() {
    super.initState();
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
    return WillPopScope(onWillPop: _onWillPop,
      child:Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: WidgetHelper().NuniyoAppBar(),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().DetailsTitle('Aadhar KYC'),
                Text("DigiLocker is a digital locker facility provided by the Government of India under its Digital India initiative. It allows all Indian citizens to store and access scanned or digital formats of their documents. It is 100% safe and just another way of validating your details. Your documents issued in DigiLocker are secure and you need to validate them with your Aadhaar number and OTP. You can check if your mobile number is linked to your Aadhaar here. If your mobile number isn't linked, you will not be able to continue with the online process.",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 20,),
                Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BrowserViewX()),
                      );
                      //Navigator.pushNamed(context, '/personaldetailsscreen');
                    },
                    color: primaryColorOfApp,
                    child: Text(
                        "Continue to DigiLocker",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Text("By proceeding further, you hereby authorize Mangal Keshav Financial Services LLP to pull your documents from DigiLocker to be used for your account opening process. Further, you provide your consent to share your details with the Income Tax Department, Government of India, All States and State Departments in connection with opening your online account with us.",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 20,),
                Text("Mangal Keshav Financial Services LLP has become an approved partner of the Government of India for using its \"consent-based requester model\" services of DigiLocker. We use these services to obtain your proof of address (your account name would be taken as per the name registered on the Income Tax database / as per your PAN) if you are not already KRA verified, and digitally signing your application form with Aadhaar eSign using NSDL (licensed ASP). We do not collect or store your Aadhaar number and neither of these services reveal your Aadhaar number to us. If you do not wish to grant us access to retrieve your documents stored in DigiLocker, please use our offline forms by visiting any of our branches or Authorized Persons.",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
              ],
            ),
          ),
        ),
      ),)
    );
  }
}
