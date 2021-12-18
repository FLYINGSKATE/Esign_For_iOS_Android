///Consists of Customized Widget(Such as Button ,Input Texts etc.)
// Made for Nuniyo to use
// By the overall screens of App
import 'package:esign/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




class WidgetHelper extends StatefulWidget {
  const WidgetHelper({Key? key}) : super(key: key);

  @override
  _WidgetHelperState createState() => _WidgetHelperState();

  Widget GradientButton(BuildContext context,var _onpressed,String BtnText) {
    return Container(
      child: RaisedButton(
        onPressed: _onpressed,
        textColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
              gradient: new LinearGradient(
                colors: [
                  Color.fromARGB(255, 127, 0, 255),
                  Color.fromARGB(255, 225, 0, 255)
                ],
              )
          ),
          padding: const EdgeInsets.all(10.0),
          child: Text(
            BtnText,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  AppBar NuniyoAppBar(){
    return AppBar(
      title: Text('Flutter ESign',style: GoogleFonts.openSans(fontSize: 18,textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontWeight: FontWeight.bold))),
      backgroundColor: secondaryColorOfApp,
      elevation: 0,
    );
  }

  

  Widget DetailsTitle(String detailsTitle){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.0,),
        Row(
          children: [
            SizedBox(width: 10.0,),
            Expanded(child:Text(detailsTitle,textAlign:TextAlign.left,
              style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 30.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0,10,0,0),
          child: Container(height: 5, width: 35,
            decoration: BoxDecoration(
                color: Color(0xffc41e1c),
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
          ),
        ),
        SizedBox(height: 20.0,),
      ],
    );
  }
}

class _WidgetHelperState extends State<WidgetHelper> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }

}