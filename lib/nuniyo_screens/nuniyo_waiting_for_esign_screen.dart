import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/globals.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WaitingScreenForESign extends StatefulWidget {
  const WaitingScreenForESign({Key? key}) : super(key: key);

  @override
  _WaitingScreenForESignState createState() => _WaitingScreenForESignState();
}

class _WaitingScreenForESignState extends State<WaitingScreenForESign> with SingleTickerProviderStateMixin{


  late Animation<double> _animation;
  late AnimationController _animationController;

  String  messageFromEsign = "Please Wait.....";

  bool showSupportContact = false;

  String supportPhoneNumber = "9967413567";
  String supportMailId = "kyc@mangalkeshav.com";

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

  @override
  void initState() {
    CheckForEsignResponse();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  CheckForEsignResponse() async {
    String EsignStatus = await ApiRepository().Get_eSign_Document_Details();
    if(EsignStatus =="true"){
      Navigator.pushReplacementNamed(context, "UCC");
    }
    else{
      messageFromEsign = EsignStatus;
      showSupportContact = true;
      setState(() {});
      Navigator.pushReplacementNamed(context, "ESign");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            //Init Floating Action Bubble
            floatingActionButton: showSupportContact?FloatingActionBubble(
              // Menu items
              items: <Bubble>[
                // Floating action menu item
                Bubble(
                  title:"Call Us",
                  iconColor :Colors.white,
                  bubbleColor : primaryColorOfApp,
                  icon:Icons.call,
                  titleStyle:TextStyle(fontSize: 16 , color: Colors.white),
                  onPress: () async {
                    _animationController.reverse();
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: supportPhoneNumber,
                    );
                    await launch(launchUri.toString());
                  },
                ),
                // Floating action menu item
                Bubble(
                  title:"Mail Us",
                  iconColor :Colors.white,
                  bubbleColor : primaryColorOfApp,
                  icon:Icons.email,
                  titleStyle:TextStyle(fontSize: 16 , color: Colors.white),
                  onPress: () {
                    _animationController.reverse();
                    String? encodeQueryParameters(Map<String, String> params) {
                      return params.entries
                          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                          .join('&');
                    }

                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: '$supportMailId',
                      query: encodeQueryParameters(<String, String>{
                        'subject': 'Help Needed Regarding Error Message : \"$messageFromEsign\"'
                      }),
                    );

                    launch(emailLaunchUri.toString());
                  },
                ),

                Bubble(
                  title:"Try Again",
                  iconColor :Colors.white,
                  bubbleColor : primaryColorOfApp,
                  icon:Icons.refresh_rounded,
                  titleStyle:TextStyle(fontSize: 16 , color: Colors.white),
                  onPress: () {
                    _animationController.reverse();
                    Navigator.pushReplacementNamed(context, "Esign");
                  },
                ),
              ],

              // animation controller
              animation: _animation,

              // On pressed change animation state
              onPress: () => _animationController.isCompleted
                  ? _animationController.reverse()
                  : _animationController.forward(),

              // Floating Action button Icon color
              iconColor: Colors.white,

              // Flaoting Action button Icon
              iconData: Icons.support_agent,
              backGroundColor: primaryColorOfApp,
            ):null,
            resizeToAvoidBottomInset: true,
            appBar: WidgetHelper().NuniyoAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "$messageFromEsign",textAlign:TextAlign.center,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                  ),
                  SizedBox(height: 20,),
                  showSupportContact?Icon(Icons.error,color: primaryColorOfApp,size: 40,):CircularProgressIndicator(color: primaryColorOfApp,),
                ],
              ),
            )
        ));
  }
}
