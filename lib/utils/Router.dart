
import 'package:flutter/material.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_aadhar_kyc_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_bank_email_pan_validation_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_commodity_upload_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_congrats_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_digilocker_web_view.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_esign_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_esign_screen_duplicate.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_mobile_validation_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_options_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_options_screen_two.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_personal_details_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_splash_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_upload_documents_and_signature.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_waiting_for_esign_screen.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_webcam_screen.dart';

/*
0) contact
1) email
2) market segment / Options / market segment
4) digiloc/aadhar kyc
5) personal info /
6) IPV / Webcam screen
7) docupload /
8) esign /
9) application status /
*/

class ScreenRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      //0
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      //0
      case 'Mobile':
        return MaterialPageRoute(builder: (_) => MobileValidationLoginScreen());
      //1
      case 'Email':
        return MaterialPageRoute(builder: (_) => BankPanEmailValidationScreen());
      //2
      case 'Account':
        return MaterialPageRoute(builder: (_) => OptionsScreenTwo());
      //3
      case 'Digilocker':
        return MaterialPageRoute(builder: (_) => AadharKYCScreen());
      //4
      case 'Personal':
        return MaterialPageRoute(builder: (_) => PersonalDetailsScreen());
      //5
      case 'IPV':
        return MaterialPageRoute(builder: (_) => WebCamScreen());
      //6
      case 'Document':
        return MaterialPageRoute(builder: (_) => UploadDocumentScreen());
      //7
      case 'Esign':
        return MaterialPageRoute(builder: (_) => EsignScreen());
      //8
      case 'UCC':
        return MaterialPageRoute(builder: (_) => CongratsScreen());
      //EXTRA
      case '/webview':
        return MaterialPageRoute(builder: (_) => BrowserViewX());
      case 'EsignResponse':
        return MaterialPageRoute(builder: (_) => EsignScreenResponse());
      case 'OPEN':
        return MaterialPageRoute(builder: (_) => CommodityDocumentUploadScreen());
    default:
      return MaterialPageRoute(builder: (_) => MobileValidationLoginScreen());
    }
  }
}