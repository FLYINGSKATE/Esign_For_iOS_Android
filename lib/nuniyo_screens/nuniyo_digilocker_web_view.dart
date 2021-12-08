import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/nuniyo_screens/nuniyo_aadhar_kyc_screen.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webviewx/webviewx.dart';

import '../globals.dart';

class BrowserViewX extends StatefulWidget {
  const BrowserViewX({Key? key}) : super(key: key);

  @override
  _BrowserViewXState createState() => _BrowserViewXState();

}

class _BrowserViewXState extends State<BrowserViewX> {

  late WebViewXController webviewController;
  String webURL = "";

  String hmac = "";
  String code = "";
  String state = "";

  bool executeOnce = false;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    initializeWebView();
  }

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop2() {
    return Future.value(false);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit DigiLocker'),
        actions: <Widget>[
          TextButton(
            onPressed:(){Navigator.pushNamed(context, 'Digilocker');},
            //onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          TextButton(
            onPressed:() {
              Navigator.pushNamed(context, 'Digilocker');
              },
            //onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: WidgetHelper().NuniyoAppBar(),
      body: WebViewX(
        key: const ValueKey('webviewx'),
        initialContent: '<h2>Please Wait........</h2>',
        initialSourceType: SourceType.html,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        onWebViewCreated: (controller) {webviewController = controller;initializeWebView();},
        onPageStarted: (src) {
          debugPrint('A new page has started loading: $src\n');
        },
        onPageFinished: (src) {
        debugPrint('The page has finished loading: $src\n');
        //print("GLJDJL:SNDLND"+src);
        if(src.contains("error")){
          //print("Error Aaya hai! SRC mien");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AadharKYCScreen()));
          //Navigator.pushReplacementNamed(context,'Digilocker');
        }
        if(src.contains("&hmac")){
          //print("Contains HMAC");
          if(!executeOnce){
            executeOnce = true;
            getCodeStateHMAC(src);
          }
        }
        else{
          //print("Don't know if contains HMAC");
          //getCodeStateHMAC(src);
        }
        },
        jsContent: const {
          EmbeddedJsContent(
            js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
          ),
          EmbeddedJsContent(
            webJs:
            "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
            mobileJs:
            "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
          ),
        },
        dartCallBacks: {
          DartCallback(
            name: 'TestDartCallback',
            callBack: (msg) => print("Waht is this ? "+msg.toString()),
          )
        },
        webSpecificParams: const WebSpecificParams(
          printDebugInfo: true,
        ),
        mobileSpecificParams: const MobileSpecificParams(
          androidEnableHybridComposition: true,
        ),
        navigationDelegate: (navigation) {
          debugPrint(navigation.content.sourceType.toString());
          //print("Navigation ka dekho "+navigation.content.source.toString());
          //print("Navigation ka Dubug ka bachan :"+navigation.content.sourceType.toString());
          return NavigationDecision.navigate;
        },
      ),
    ), onWillPop: _onWillPop2);
  }

  Future<void> initializeWebView() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lead_id= prefs.getString(LEAD_ID_KEY);
    await webviewController.loadContent(
      'https://api.digitallocker.gov.in/public/oauth2/1/authorize?response_type=code&client_id=2D9675AB&state=$lead_id&redirect_uri=https://mkyc.mangalkeshav.com/digilocker/index.html',
      SourceType.url,
    );
  }

  Future<void> ContinueToStep() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ThisStepId = prefs.getString(STAGE_KEY);
    //print("YOU LEFT ON THIS PAGE LAST TIME"+ThisStepId);
    Navigator.pushNamed(context,ThisStepId);
  }


  Future<void> getCodeStateHMAC(String string) async {
    //print("We got this as a url string"+string);

    if(string==""){
      string = 'http://localhost:3000/Redirect?code=a4cda096cd6cfe5a89307ca26d24f69c994828bf&state=T001211000081&hmac=ba2c9cddb8606e78f634f7da0b7e60ee1aa41d51392fa2acf83c42428c98264f';
    }

    //print(string.indexOf('code='));
    //print(string.indexOf('state='));
    //print(string.indexOf('hmac='));

    String start = 'code=';
    String end = '&state';

    int startIndex = string.indexOf(start);
    int endIndex = string.indexOf(end);
    String code = string.substring(startIndex + start.length, endIndex).trim();
    //print("CODE");
    //print(code);

    start = "state=";
    end = "&hmac";

    startIndex = string.indexOf(start);
    endIndex = string.indexOf(end);
    String state = string.substring(startIndex + start.length, endIndex).trim();
    //print("STATE");
    //print(state);

    start = "hmac=";


    startIndex = string.indexOf(start);
    endIndex = string.length;
    String hmac = string.substring(startIndex + start.length, endIndex).trim();
    //print("HMAC");
    //print(hmac);

    String address = await ApiRepository().GetAuthorizationCode(hmac, code, state);

    showAlertDialog(context,address);
    await ApiRepository().UpdateStage_Id();
    await Future.delayed(const Duration(seconds: 10), (){});
    Navigator.of(context).pop();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stage_id = prefs.getString(STAGE_KEY);
    //print("Let\'s go To");
    //print(stage_id);
    Navigator.pushNamed(context, stage_id);
    //print(code);
    //print(hmac);
    //print(state);
  }

  showAlertDialog(BuildContext context,String address) {
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
        title: Text("Please Wait",style: GoogleFonts.openSans(
          textStyle: TextStyle(
              color: Colors.black,
              letterSpacing: .5,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        )),
        content: SingleChildScrollView(
          child:Column(
            children: [
              Text("$address",style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Colors.black,
                  letterSpacing: .5,
                  fontSize: 14,
                ),
              )),

              CircularProgressIndicator(color: primaryColorOfApp,)
            ],
          ),
          ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)))
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
