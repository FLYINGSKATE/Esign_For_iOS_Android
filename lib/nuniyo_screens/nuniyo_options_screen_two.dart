import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

class OptionsScreenTwo extends StatefulWidget {
  const OptionsScreenTwo({Key? key}) : super(key: key);


  @override
  _OptionsScreenTwoState createState() => _OptionsScreenTwoState();
}

class _OptionsScreenTwoState extends State<OptionsScreenTwo> {

  String total= "0";

  bool checkedValue  = false;

  static const platform = const MethodChannel("razorpay_flutter");

  late Razorpay _razorpay;

  String? _groupValue;

  String amount="";

  bool enablePaymentButton = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0,),
                    Row(
                      children: [
                        SizedBox(width: 10.0,),
                        Text("Select Brokerage Plan",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                        //Text(" ₹ $total",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                      ],
                    ),
                   Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,10,0,0),
                      child: Container(height: 5, width: 35,
                        decoration: BoxDecoration(
                            color: primaryColorOfApp,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                  ],
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: _groupValue=="platinum"?210:100,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Radio(
                              value: "platinum",
                              groupValue: _groupValue,
                              onChanged: (String? value) {
                                setState(() {
                                  _groupValue = value;
                                  total = "1250";
                                  //print(_groupValue);
                                });
                              },
                            ),),
                            Expanded(
                              flex:5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Platinum",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                              ),
                            ),
                            Text("₹1,250",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)
                          ],
                        ),
                        Visibility(child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("1) Upfront Margin", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                    Text("₹100,000", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("2) Intraday", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("0.01%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("3) Delivery", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("0.10%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("4) Options/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("₹10", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("5) Currency/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("₹5", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                              ],
                            )
                        ),visible: _groupValue=="platinum",)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: _groupValue=="gold"?210:100,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Radio(
                                value: "gold",
                                groupValue: _groupValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    _groupValue = value;
                                    total = "550";
                                    //print(_groupValue);
                                  });
                                },
                              ),),
                            Expanded(
                              flex:5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Gold",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                              ),
                            ),
                            Text("₹550",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)
                          ],
                        ),
                        Visibility(visible: _groupValue=="gold",child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1) Upfront Margin", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  Text("₹25,000", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("2) Intraday", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.03%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Delivery", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.30%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("4) Options/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹30", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Currency/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹10", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: _groupValue=="silver"?210:100,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Radio(
                                value: "silver",
                                groupValue: _groupValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    _groupValue = value;
                                    total = "300";
                                    //print(_groupValue);
                                  });
                                },
                              ),),
                            Expanded(
                              flex:5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Silver",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                              ),
                            ),
                            Text("₹300",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)
                          ],
                        ),
                        Visibility(visible: _groupValue=="silver",child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1) Upfront Margin", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  Text("₹5,000", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("2) Intraday", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.05%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Delivery", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.50%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("4) Options/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹50", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Currency/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹20", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                            ],
                          ),
                        ),)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Divider(
                  height: 20,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Total",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color:primaryColorOfApp,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold))),
                    Text("₹ $total",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color:primaryColorOfApp,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold))),
                  ],
                ),
                Divider(
                  height: 20,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(height: 30,),
                Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  child: FlatButton(
                    disabledTextColor: Colors.blue,
                    disabledColor: secondaryColorOfApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: (_groupValue==null || enablePaymentButton)?null:() async {
                      int planID  = 0;
                      if(_groupValue == "gold"){
                        planID = 1;
                      }
                      else if(_groupValue=="silver"){
                        planID = 2;
                      }
                      String? orderID = await ApiRepository().RazorPayment_MarketSegment(planID);
                      openCheckout(orderID);

                      //Navigator.pushNamed(context, 'Digilocker');
                    },
                    color: primaryColorOfApp,
                    child: enablePaymentButton?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Please Wait",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width:20,),
                        CircularProgressIndicator(color: Colors.white,),
                      ],
                    ):Text(
                        "Proceed",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0,10.0,0.0,0.0),
                  child: Text("* You can create F&O and Commodity account after equity account opening is completed." ,textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(height:2,color: Colors.black,fontSize: 10.0,letterSpacing: .5)),),
                ),
              ],
            ),
          ),
        ),
      ),)
    );
  }

  void openCheckout(String? orderID) async {
    enablePaymentButton = true;
    setState(() {
      
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber= prefs.getString(MOBILE_NUMBER_KEY);
    String emailID = prefs.getString('EMAIL_ID');

    amount = (int.parse(total)*100).toString();
    //String amount = "100";
    var options = {
      'key': 'rzp_live_q8gUCOxfHIbCkb',
      //'key': 'rzp_test_dojmbldJSpz91g',
      //'amount': amount,
      'amount': "100",
      //"order_id":"$orderID",
      'name': 'TecXLabs',
      'description': 'Stock Trading',
      'prefill': {'contact': '$phoneNumber', 'email': '$emailID'},
    };

    if(orderID==null||orderID==""){
      options = {
        'key': 'rzp_live_q8gUCOxfHIbCkb',
        //'key': 'rzp_test_dojmbldJSpz91g',
        //'amount': amount,
        'amount': "100",
        //"order_id":"$orderID",
        'name': 'TecXLabs',
        'description': 'Stock Trading',
        'prefill': {'contact': '$phoneNumber', 'email': '$emailID'},
      };
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    enablePaymentButton = true;
    setState(() {
      
    });
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_SHORT);
    //print("Razor Payment Success SIGNATURE"+response.signature.toString());
    //print("Razor Payment Success ORDER ID"+response.signature.toString());
    PostPayment(response.paymentId.toString(),response.signature.toString(),response.orderId.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    enablePaymentButton = false;
    setState(() {

    });
    Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message!, toastLength: Toast.LENGTH_SHORT);
    //print("Payment Error");
    //print(response.code.toString());
    //print(response.message.toString());
    Navigator.pushNamed(context, 'Account');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  Future<void> PostPayment(String paymentID,String signature,String merchantID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = await prefs.getString(MOBILE_NUMBER_KEY);
    ///ApiRepo().OnPaymentSuccessPostToDatabase(200, phoneNumber,paymentID);
    //await LocalApiRepo().RazorPayStatusLocal(200, 'INR', phoneNumber, paymentID);
    String depositoryCharge = "0";
    switch(_groupValue){
      case "platinum":
        depositoryCharge = "1";
        break;
      case "gold":
        depositoryCharge = "2";
        break;
      case "silver":
        depositoryCharge = "3";
        break;
    }
    //In Place of Signature I'm Sending Payment Plan Id
    //await ApiRepository().RazorPaymentStatus("200", merchantID, paymentID, signature);
    await ApiRepository().RazorPaymentStatus("$amount", merchantID, paymentID, depositoryCharge);
    await ApiRepository().UpdateStage_Id();
    String ThisStepId = prefs.getString(STAGE_KEY);
    //print("YOU LEFT ON THIS PAGE LAST TIME"+ThisStepId);
    Navigator.pushNamed(context,ThisStepId);
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

}
