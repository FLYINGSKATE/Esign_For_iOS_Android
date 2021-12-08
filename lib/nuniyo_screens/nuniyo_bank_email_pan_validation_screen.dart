///Sign Up Page 1
import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/utils/encode_decode.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../globals.dart';

extension DateTimeX on DateTime {
  bool isUnderage() =>
      (DateTime(DateTime.now().year, this.month, this.day)
          .isAfter(DateTime.now())
          ? DateTime.now().year - this.year - 1
          : DateTime.now().year - this.year) < 18;
}


/////Bank
class BankPanEmailValidationScreen extends StatefulWidget {
  const BankPanEmailValidationScreen({Key? key}) : super(key: key);

  @override
  _BankPanEmailValidationScreenState createState() =>
      _BankPanEmailValidationScreenState();
}

class _BankPanEmailValidationScreenState
    extends State<BankPanEmailValidationScreen> {


  //Current Screen Text Field
  TextEditingController _ifscCodeTextEditingController = TextEditingController();
  TextEditingController _bankTextEditingController = TextEditingController();
  TextEditingController _panTextEditingController = TextEditingController();
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _dateController = TextEditingController();


  ///Dialog Box Text Field
  TextEditingController _ifscCodeDialogTextEditingController = TextEditingController();
  TextEditingController _branchLocationTextEditingController = TextEditingController();
  TextEditingController _branchNameTextEditingController = TextEditingController();

  late FocusNode _branchNameTextFieldFocusNode, _branchLocationTextFieldFocusNode, _IFSCCode2TextFieldFocusNode;

  bool isValidIFSCCode = false;

  String emailErrorText = "Please Enter a valid Email...";
  bool showEmailErrorText = false;

  bool showIFSCErrorText = false;
  String ifscErrorText = "Please Enter a valid IFSC....";

  String panErrorText = "Please Enter a valid PAN Number...";
  bool showPANErrorText = false;

  bool enableIFSCCodeTextField = false;

  Map IFSCMapList = {};

  bool showIFSCSearchResults = false;

  bool showBranchLocationErrorText = false;
  bool showBranchNameErrorText = false;

  String branchNameErrorText = "Please Enter a Valid Branch Name";
  String branchLocationErrorText = "Please Enter a Valid Branch Location";

  String BankAccountNumberErrorText = "Please Enter a Valid Bank Account Number";
  bool showBankAccountNumberErrorText = false;

  bool isValidBankAccount = false;

  bool showDOBError = false;

  bool showSearchYourIFSCFields = true;

  String? _selectedDate;

  bool enableBankAccountTextField = false;
  bool enableDatePicker = false;

  String emailString = "";

  void _requestBankNameTextFieldFocusNode() {
    setState(() {
      FocusScope.of(context).requestFocus(_branchNameTextFieldFocusNode);
    });
  }

  void _requestBranchNameFocusNode() {
    setState(() {
      FocusScope.of(context).requestFocus(_branchLocationTextFieldFocusNode);
    });
  }

  void _requestIFSCCode2TextFieldFocusNode() {
    setState(() {
      FocusScope.of(context).requestFocus(_IFSCCode2TextFieldFocusNode);
    });
  }


  _selectDate(BuildContext context) async {
    _requestDateTextFieldFocus();
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColorOfApp, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: primaryColorOfApp, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDatePickerMode: DatePickerMode.year,
        initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: DateTime(DateTime.now().year-25, DateTime.now().month, DateTime.now().day),
        firstDate: DateTime(DateTime.now().year-200, DateTime.now().month, DateTime.now().day),
        lastDate: DateTime(DateTime.now().year-18, DateTime.now().month, DateTime.now().day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        if(selectedDate.isUnderage()){
          ///Show Snackbar here and exit date picker and
          (selectedDate);
          ("You are Underage ");
          showDOBError = true;
          ///
        }
        else{
          var date =
              "${picked.toLocal().day}-${picked.toLocal().month}-${picked.toLocal().year}";
          _dateController.text = date;
          ("WE SELECTED A DATE");
          postDateToDB();
        }
      });
  }

  DateTime selectedDate = DateTime.now();

  bool isPanValidatedSuccessfully = false;
  bool isBankValidatedSuccessfully = false;
  bool isEmailValidatedSuccessfully = false;
  bool isIFSCValidatedSuccessfully = false;
  bool isDOBValidatedSuccessfully = false;

  bool isValidInputForPan = false;
  bool isValidInputForBank = false;
  bool isValidInputForIFSC = false;
  bool isValidInputForEmail = false;


  ///Current Screen Focus Node
  late FocusNode _emailTextFieldFocusNode, _dateTextFieldFocusNode,
      _panTextFieldFocusNode,
      _bankTextFieldFocusNode,
      _ifscTextFieldFocusNode;


  @override
  void initState() {
    super.initState();
    //manageSteps();
    _branchNameTextFieldFocusNode = FocusNode();
    _branchLocationTextFieldFocusNode = FocusNode();
    _IFSCCode2TextFieldFocusNode = FocusNode();
    _emailTextFieldFocusNode = FocusNode();
    _panTextFieldFocusNode = FocusNode();
    _bankTextFieldFocusNode = FocusNode();
    _ifscTextFieldFocusNode = FocusNode();
    _dateTextFieldFocusNode = FocusNode();
  }

  void _requestEmailIdTextFieldFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_emailTextFieldFocusNode);
    });
  }

  void _requestDateTextFieldFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_dateTextFieldFocusNode);
    });
  }

  void _requestPanTextFieldFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_panTextFieldFocusNode);
    });
  }

  void _requestBankTextFieldFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_bankTextFieldFocusNode);
    });
  }

  void _requestIfscTextFieldFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(_ifscTextFieldFocusNode);
    });
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

  @override
  void dispose() {
    _ifscCodeTextEditingController.dispose();
    _bankTextEditingController.dispose();
    _panTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _dateController.dispose();


    ///Dialog Box Text Field
    _ifscCodeDialogTextEditingController.dispose();
    _branchLocationTextEditingController.dispose();
    _branchNameTextEditingController.dispose();

    _branchNameTextFieldFocusNode.dispose();
    _branchLocationTextFieldFocusNode.dispose();
    _IFSCCode2TextFieldFocusNode.dispose();
    _emailTextFieldFocusNode.dispose();
    _bankTextFieldFocusNode.dispose();
    _ifscTextFieldFocusNode.dispose();
    _panTextFieldFocusNode.dispose();
    _dateTextFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: WidgetHelper().NuniyoAppBar(),
          body: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.0),
                    WidgetHelper().DetailsTitle('Let\'s get started'),
                    //SizedBox(height: 20,),
                    Flexible(
                        child: TextField(
                          enabled: !isEmailValidatedSuccessfully,
                      cursorColor: primaryColorOfApp,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      focusNode: _emailTextFieldFocusNode,
                      controller: _emailTextEditingController,
                      onTap: _requestEmailIdTextFieldFocus,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(20.0),
                          counter: Offstage(),
                          suffixIcon: (isValidInputForEmail&&isEmailValidatedSuccessfully)?Icon(Icons.check_circle,color:Colors.green):!isEmailValidatedSuccessfully?Padding(
                              padding: EdgeInsets.all(8)
                              ,child:SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: (_emailTextFieldFocusNode.hasFocus&&isValidInputForEmail)?primaryColorOfApp:Colors.transparent,
                              ))
                          ):Icon(Icons.error,color:isValidInputForEmail?Colors.red:Colors.transparent),
                          errorText: showEmailErrorText ? emailErrorText : null,
                          labelText: _emailTextFieldFocusNode.hasFocus
                              ? 'Email ID'
                              : 'Enter Email ID',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _emailTextFieldFocusNode.hasFocus
                                ? primaryColorOfApp
                                : Colors.grey,
                          )),
                      onSubmitted: (value){
                            if(!isEmailValidatedSuccessfully){
                              showEmailErrorText = true;
                              setState(() {});
                            }
                      },
                      onChanged: (_emailID) async {
                        (_emailID.length);
                        if(!_emailID.contains("@")){
                          showEmailErrorText = false;
                          setState(() {

                          });
                          return;
                        }
                        if(!_emailID.contains(".")){
                          showEmailErrorText = false;
                          setState(() {

                          });
                          return;
                        }
                        if(_emailID.length<=4){
                          setState(() {

                          });
                          showEmailErrorText = false;
                          return;
                        }
                        if (!EmailValidator.validate(_emailID)) {
                          ('Enter a valid email address');
                          isValidInputForEmail = false;
                          showEmailErrorText = true;
                          isEmailValidatedSuccessfully = false;
                          //setState(() {

                          //});
                        } else {
                          ("Noice Email");
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          isValidInputForEmail = true;
                          setState(() {});
                          //isValidInputForEmail = await ApiRepo().VerifyEmail(prefs.getString('PhoneNumber'), _emailID);
                          //Send Email ID to APi
                          //enableEmailIDTextField = false;
                          isEmailValidatedSuccessfully = await ApiRepository().Email_Status(_emailID);
                          emailString = _emailID;
                          showEmailErrorText = !isEmailValidatedSuccessfully;
                          setState(() {

                          });
                          if(!isEmailValidatedSuccessfully){
                            //enableEmailIDTextField = true;
                          }
                          if(isEmailValidatedSuccessfully){
                            await ApiRepository().UpdateEmail(_emailID);
                            _emailID = emailString;
                          }
                          if (isEmailValidatedSuccessfully) {
                            _requestPanTextFieldFocus();
                            prefs.setString(EMAIL_ID_KEY, _emailID);
                          }
                          setState(() {});
                        }
                      },
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                        child: TextField(

                        textCapitalization: TextCapitalization.characters,
                        inputFormatters:<TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                        ],
                        maxLength: 10,
                        onChanged: (_panNumber) async {
                        if (_panNumber.length >= 10) {
                          isValidInputForPan = true;
                          setState(() {

                          });
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          //isValidInputForPan = await ApiRepo().VerifyPAN(phoneNumber, _panNumber);
                          //isPanValidatedSuccessfully = await LocalApiRepo().NSDLeKYCPanAuthenticationLocal(_panNumber);

                          FocusScope.of(context).unfocus();
                          prefs.setString(PAN_NO_KEY, _panNumber);
                          if(_dateController.text.isNotEmpty){
                            postDateToDB();
                            return;
                          }

                          enableDatePicker = true;
                          _requestDateTextFieldFocus();
                          setState(() {});
                        }
                      },
                      controller: _panTextEditingController,
                      cursorColor: primaryColorOfApp,
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      focusNode: _panTextFieldFocusNode,
                      onTap: _requestPanTextFieldFocus,
                      enabled: isEmailValidatedSuccessfully && !isPanValidatedSuccessfully,
                      decoration: InputDecoration(
                          errorText: showPANErrorText ? panErrorText : null,
                          counter: Offstage(),
                          suffixIcon: (isValidInputForPan&&isPanValidatedSuccessfully)?Icon(Icons.check_circle,color:Colors.green):!isPanValidatedSuccessfully?Padding(
                              padding: EdgeInsets.all(8)
                              ,child:SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: (_panTextFieldFocusNode.hasFocus&&isValidInputForPan)?primaryColorOfApp:Colors.transparent,
                              ))
                          ):Icon(Icons.error,color:isValidInputForPan?Colors.red:Colors.transparent),
                          labelText: _panTextFieldFocusNode.hasFocus
                              ? 'Enter PAN Number'
                              : 'Enter PAN Number',
                          labelStyle: TextStyle(
                            color: _panTextFieldFocusNode.hasFocus
                                ? primaryColorOfApp
                                : Colors.grey,
                          )),

                    )),
                    SizedBox(
                      height: 10,
                    ),
                    //DOB
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: GestureDetector(
                        onTap:enableDatePicker?(){
                          FocusScope.of(context).unfocus();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: Text('Select Date Of Birth'),
                                    content: Container(
                                      height: 400,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            height: 400,
                                            width: 400,
                                            child: getDateRangePicker(),
                                          ),
                                        ],
                                      ),
                                    ));
                              });
                        }:null,
                        child: AbsorbPointer(
                          child: TextField(
                            enabled: enableDatePicker,
                            cursorColor: primaryColorOfApp,
                            style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: _dateTextFieldFocusNode.hasFocus?Colors.black:Colors.black,
                                    letterSpacing: .5,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            onTap: _requestDateTextFieldFocus,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(icon:Icon(Icons.date_range, color:_dateTextFieldFocusNode.hasFocus?primaryColorOfApp:Colors.grey),onPressed:enableDatePicker? (){getDateRangePicker();}:null),
                              errorText: showDOBError?"Enter a valid DOB":null,
                              labelText: _dateTextFieldFocusNode.hasFocus
                                  ? 'Enter DOB'
                                  : 'Enter DOB',
                              labelStyle: TextStyle(
                                color: _dateTextFieldFocusNode.hasFocus
                                    ? primaryColorOfApp
                                    : Colors.grey,
                              ),
                              contentPadding: EdgeInsets.only(top:20,bottom: 20,left: 25),
                              hintText: 'DD/MM/YYYY',
                            ),
                            controller: _dateController,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Flexible(child: TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      ],
                      keyboardType: TextInputType.number,
                      enabled: enableBankAccountTextField ,
                      textCapitalization: TextCapitalization.characters,
                      controller: _bankTextEditingController,
                      onChanged: (value) async {
                        if(value.length>18 || value.length>9){
                          ("Verifying Bank Account");
                          isValidBankAccount = true;
                          isValidInputForBank = true;
                          isBankValidatedSuccessfully = true;
                          showBankAccountNumberErrorText = !isValidBankAccount;
                          enableIFSCCodeTextField = true;
                          setState((){});
                        }
                      },
                      cursorColor: primaryColorOfApp,
                      maxLength: 16,
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      focusNode: _bankTextFieldFocusNode,
                      onTap: _requestBankTextFieldFocus,
                      decoration: InputDecoration(
                          counter: Offstage(),
                          errorText: showBankAccountNumberErrorText ? "Enter a valid Bank A/C No." : null,
                          suffixIcon:(isValidInputForBank&&isBankValidatedSuccessfully)?Icon(Icons.check_circle,color:Colors.green):!isBankValidatedSuccessfully?Padding(
                          padding: EdgeInsets.all(8)
                          ,child:SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: (_bankTextFieldFocusNode.hasFocus&&isValidInputForBank)?primaryColorOfApp:Colors.transparent,
                          ))
                      ):Icon(Icons.error,color:isValidInputForBank?Colors.red:Colors.transparent),
                          labelText: _bankTextFieldFocusNode.hasFocus
                              ? 'Enter Bank A/C Number'
                              : 'Enter Bank A/C Number',
                          labelStyle: TextStyle(
                            color: _bankTextFieldFocusNode.hasFocus
                                ? primaryColorOfApp
                                : Colors.grey,
                          )),
                    )),
                    SizedBox(height: 20,),
                    Flexible(child: TextField(
                      maxLength: 11,
                      textCapitalization: TextCapitalization.characters,
                      controller: _ifscCodeTextEditingController,
                      cursorColor: ifscColorTextField(),
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      focusNode: _ifscTextFieldFocusNode,
                      enabled: enableIFSCCodeTextField,
                      onTap: _requestIfscTextFieldFocus,
                      onChanged: (value) {
                        if(!isIFSCValidatedSuccessfully){
                          validateIFSC(value);
                        }
                        },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                      ],
                      decoration: InputDecoration(
                          counter: Offstage(),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey,width: 0),
                          ),
                          errorText: showIFSCErrorText ? "Enter a valid IFSC" : null,
                          suffixIcon: !showIFSCErrorText
                              ? Icon(Icons.check_circle,
                                  color: isIFSCValidatedSuccessfully
                                      ? Colors.green
                                      : Colors.transparent)
                              : Icon(Icons.error, color: Colors.red),
                          labelText: _ifscTextFieldFocusNode.hasFocus
                              ? 'Enter IFSC Number'
                              : 'Enter IFSC Number',
                          labelStyle: TextStyle(
                            color: _ifscTextFieldFocusNode.hasFocus
                                ? isIFSCValidatedSuccessfully?Colors.grey:primaryColorOfApp
                                : Colors.grey,
                          )),
                    )),
                    Visibility(visible:true,child:Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.search,
                            color: enableIFSCCodeTextField?primaryColorOfApp:secondaryColorOfApp,
                            size: 26,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          TextButton(
                              onPressed:enableIFSCCodeTextField?() {
                                openIFSCSearchDialogBox();
                              }:null,
                              child: Text(
                                "Find Your IFSC Code",
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: enableIFSCCodeTextField?primaryColorOfApp:secondaryColorOfApp,
                                      letterSpacing: .5),
                                ),
                              )),
                        ],
                      ),
                    )),
                    SizedBox(height: 30,),
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: _onWillPop);
  }

  Color ifscColorTextField() {
    if (_ifscCodeTextEditingController.text.length == 11 && isValidIFSCCode) {
      return Colors.green;
    } else if (_ifscCodeTextEditingController.text.length == 11 &&
        !isValidIFSCCode) {
      return Colors.red;
    } else if (_ifscTextFieldFocusNode.hasFocus) {
      return primaryColorOfApp;
    } else {
      return Colors.grey;
    }
  }

  void openIFSCConfirmDialogBox(String _ifscCodeR, String _bankNameR, String _addressR,String result) {
    String confirmBtnText = "Confirm";
    bool enableConfirmButton = true;
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(builder: (context,setState){
          return Align(alignment: Alignment.center,child:Container(
            height: 450,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22.0, 0.0, 0, 0),
                    child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Confirm Bank Details",
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .5,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 10.0, 0.0),
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      _ifscCodeTextEditingController.text = "";
                                      _ifscCodeDialogTextEditingController.text = "";
                                      _branchLocationTextEditingController.text = "";
                                      IFSCMapList.clear();
                                      showIFSCSearchResults = false;
                                      isIFSCValidatedSuccessfully = false;
                                      isValidIFSCCode = false;
                                      isValidInputForIFSC = false;
                                      enableIFSCCodeTextField = true;
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text("IFSC Code :",
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: .5,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Padding(padding:EdgeInsets.only(left: 18),child:Text(_ifscCodeR,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: .5,
                                        fontSize: 18),
                                  )),)
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text("Bank Name :",
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: .5,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Text(_bankNameR,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: .5,
                                        fontSize: 18),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Address :",
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: .5,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Flexible(
                                child: Align(alignment: Alignment.centerRight,child:Padding(padding:EdgeInsets.only(right: 20,left:34),child:Text(_addressR,
                                  style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: .5,
                                          fontSize: 16)),
                                )),
                                ),)
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Padding(padding:EdgeInsets.only(right: 25),child:Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 60,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onPressed: enableConfirmButton ?() async {
                                enableConfirmButton = false;
                                confirmBtnText = "Please Wait ";
                                setState((){});
                                //Penny Drop Api Will Come here till then suppose it is valid
                                await ApiRepository().ConfirmIFSCDetails(result);
                                isBankValidatedSuccessfully = await ApiRepository().verifyBankAccountLocal(_bankTextEditingController.text.trim(), _ifscCodeTextEditingController.text.trim());


                                if(!isBankValidatedSuccessfully){
                                  showBankAccountNumberErrorText = true;
                                  _ifscCodeTextEditingController.text="";
                                  isValidInputForIFSC = false;
                                  isIFSCValidatedSuccessfully  = false;
                                  Navigator.pop(context);
                                  setState(() {});
                                  _requestBankTextFieldFocus();
                                  return;
                                }
                                if(isBankValidatedSuccessfully){
                                  isValidIFSCCode = true;
                                  isValidInputForIFSC = true;
                                  isIFSCValidatedSuccessfully = true;
                                  enableIFSCCodeTextField = false;
                                  enableBankAccountTextField = false;
                                }
                                //validateIFSC(_ifscCodeTextEditingController.text);

                                ////////////////////////////Proceed Event////////////////////
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString(DATE_OF_BIRTH_KEY, _dateController.text);
                                prefs.setString(BANK_ACC_KEY, _bankTextEditingController.text);
                                await ApiRepository().UpdateStage_Id();
                                String stage_id = prefs.getString(STAGE_KEY);
                                ("On Proceed Let's go to :"+stage_id);
                                Navigator.pushNamed(context, stage_id);

                                //validateIFSC(_ifscCodeTextEditingController.text);
                              }:null,
                              disabledColor: Colors.black12,
                              disabledTextColor: Colors.white,
                              color: primaryColorOfApp,
                              child: Text("$confirmBtnText",
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: .5,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          )),
                          SizedBox(height: 20.0),
                          Padding(padding:EdgeInsets.only(right: 25),child:Container(
                            color: Colors.transparent,
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 60,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onPressed: () async {
                                _ifscCodeTextEditingController.text = "";
                                isIFSCValidatedSuccessfully = false;
                                isValidIFSCCode = false;
                                isValidInputForIFSC = false;
                                enableIFSCCodeTextField = true;
                                Navigator.pop(context);
                                setState(() {});
                              },
                              color: Colors.black12,
                              child: Text("Cancel",
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: .5,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          )),
                          SizedBox(height: 20.0),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center),
                  ),
                ),
              ),
            ),
            margin: EdgeInsets.only(bottom: 20, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ));
        });
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void openIFSCSearchDialogBox() {
    String headerTitle = "Find Your IFSC";
    showDialog(
        barrierLabel: "Barrier",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(child: StatefulBuilder(builder: (context, setState) {
            return Align(
              alignment: Alignment.center,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ), height: 550,child:Material(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    height: 550,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        child: Column(
                            children: [
                              Padding(
                                  padding:
                                  const EdgeInsets.fromLTRB(22.0, 0.0, 0.0, 10.0),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("$headerTitle",
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: .5,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold),
                                              )),
                                          Visibility(visible:false,child:Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 0.0, 10.0, 0.0),
                                            child: IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                _ifscCodeDialogTextEditingController.text = "";

                                                _branchLocationTextEditingController.text = "";
                                                IFSCMapList.clear();
                                                showIFSCSearchResults = false;
                                                _ifscCodeTextEditingController.text = "";

                                                isIFSCValidatedSuccessfully = false;
                                                isValidIFSCCode = false;
                                                isValidInputForIFSC = false;
                                                enableIFSCCodeTextField = true;
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                            ),
                                          ),)
                                        ],
                                      ))),

                              SizedBox(height: 10),
                              Visibility(visible:IFSCMapList.isEmpty,
                                child:Column(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      height: 80,
                                      child: TextField(
                                        inputFormatters: [UpperCaseTextFormatter(),],
                                        //onChanged: (value) {
                                        //if(!isIFSCValidatedSuccessfully){
                                        //validateIFSC(value);
                                        //}
                                        //},
                                        maxLength: 11,
                                        textCapitalization: TextCapitalization.characters,
                                        cursorColor: primaryColorOfApp,
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                letterSpacing: 0.5,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        focusNode: _IFSCCode2TextFieldFocusNode,
                                        onTap: _requestIFSCCode2TextFieldFocusNode,
                                        decoration: InputDecoration(
                                            errorText: showIFSCErrorText ? "Enter a valid IFSC" : null,
                                            suffixIcon: !showIFSCErrorText
                                                ? Icon(Icons.check_circle,
                                                color: isIFSCValidatedSuccessfully
                                                    ? Colors.green
                                                    : Colors.transparent)
                                                : Icon(Icons.error, color: Colors.red),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                25.0, 40.0, 0.0, 40.0),
                                            counter: Offstage(),
                                            labelText: _IFSCCode2TextFieldFocusNode
                                                .hasFocus
                                                ? 'Enter IFSC Code'
                                                : 'Enter IFSC Code',
                                            labelStyle: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  letterSpacing: 0.5,
                                                  color: _IFSCCode2TextFieldFocusNode
                                                      .hasFocus
                                                      ? primaryColorOfApp
                                                      : Colors.grey,
                                                ))),
                                      ),
                                    ),
                                  ),
                                  Text("Or",
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            letterSpacing: .5,
                                            fontSize: 20),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      height: 80,
                                      child: TextField(
                                        cursorColor: primaryColorOfApp,
                                        controller:
                                        _branchNameTextEditingController,
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                letterSpacing: 0.5,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        focusNode: _branchNameTextFieldFocusNode,
                                        onTap: _requestBankNameTextFieldFocusNode,
                                        decoration: InputDecoration(
                                            errorText: showBranchNameErrorText
                                                ? branchNameErrorText
                                                : null,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                25.0, 40.0, 0.0, 40.0),
                                            counter: Offstage(),
                                            labelText: _branchNameTextFieldFocusNode
                                                .hasFocus
                                                ? 'Enter Bank Name'
                                                : 'Enter Bank Name',
                                            labelStyle: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  letterSpacing: 0.5,
                                                  color: _branchNameTextFieldFocusNode
                                                      .hasFocus
                                                      ? primaryColorOfApp
                                                      : Colors.grey,
                                                ))),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Container(
                                      height: 80,
                                      child: TextField(
                                        cursorColor: primaryColorOfApp,
                                        controller:
                                        _branchLocationTextEditingController,
                                        style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                                color: Colors.black,
                                                letterSpacing: 0.5,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        focusNode:
                                        _branchLocationTextFieldFocusNode,
                                        onTap: () {
                                          _requestBranchNameFocusNode;
                                        },
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                25.0, 40.0, 0.0, 40.0),
                                            counter: Offstage(),
                                            errorText: showBranchLocationErrorText
                                                ? branchLocationErrorText
                                                : null,
                                            labelText:
                                            _branchLocationTextFieldFocusNode
                                                .hasFocus
                                                ? 'Enter Branch Location'
                                                : 'Enter Branch Location',
                                            labelStyle: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  letterSpacing: 0.5,
                                                  color:
                                                  _branchLocationTextFieldFocusNode
                                                      .hasFocus
                                                      ? primaryColorOfApp
                                                      : Colors.grey,
                                                ))),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 1.5,
                                      color: Colors.transparent,
                                      height: 60,
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        onPressed: () async {
                                          if (_branchNameTextEditingController.text !=
                                              "" &&
                                              _branchLocationTextEditingController.text !=
                                                  "") {
                                            showBranchNameErrorText = false;
                                            showBranchLocationErrorText = false;
                                            //IFSCMapList = await ApiRepo().searchIFSCCodes(_branchNameTextEditingController.text.trim(), _branchLocationTextEditingController.text.trim());
                                            IFSCMapList = await ApiRepository().IFSCMasterSearchLocal(_branchNameTextEditingController.text.trim(), _branchLocationTextEditingController.text.trim());
                                            if (IFSCMapList["res_Output"].length > 0) {
                                              showIFSCSearchResults = true;
                                              headerTitle = "Tap On Your IFSC Code";
                                              setState(() {});
                                            }
                                          } else {
                                            showBranchNameErrorText = true;
                                            showBranchLocationErrorText = true;
                                            setState(() {});
                                          }
                                        },
                                        color: primaryColorOfApp,
                                        child: Text("Search",
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  letterSpacing: .5,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                      ),
                                    ),
                                  ),

                                ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),),
                              ListViewOfIFSCCode()
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center),
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 20, left: 12, right: 12,top: 40),
                  )
              )),
            );
          }), onWillPop:() {
            _ifscCodeTextEditingController.text = "";
            _ifscCodeDialogTextEditingController.text = "";
            _branchLocationTextEditingController.text = "";
            IFSCMapList.clear();
            showIFSCSearchResults = false;
            isIFSCValidatedSuccessfully = false;
            isValidIFSCCode = false;
            isValidInputForIFSC = false;
            enableIFSCCodeTextField = true;
            Navigator.pop(context);
            setState(() {});
            return Future.value(true);
          });
        });
  }


  Widget ListViewOfIFSCCode() {
    if (IFSCMapList.isEmpty) {
      return Material(
        color: Colors.white,
        child: Container(
          height: 200,
        ),
      );
    } else {
      return Material(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Search Results",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: .5,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                alignment: Alignment.centerLeft,
              ),
              for (int i = 0; i < IFSCMapList["res_Output"].length; i++)IFSCCard(
                    IFSCMapList["res_Output"][i]["branch"],
                    IFSCMapList["res_Output"][i]["address"],
                    IFSCMapList["res_Output"][i]["ifsc"]),
            ],
          ),
        ),
      );
    }
  }

  IFSCCard2(String BranchName, String Address, String IfscCode) {
    String _character = "IFSC";
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: EdgeInsets.all(10),
        child:RadioListTile<String?>(
          title: Column(
            children: [
              Row(
                children: [
                  Text("IFSC Code :",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: .5,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                  Text("$IfscCode",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black, letterSpacing: .5, fontSize: 18),
                      )),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: Text("$BranchName",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address :",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: .5,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                  Flexible(
                    child: Text("$Address",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 18),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 1,
                color: Colors.black,
              ),
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          value: BranchName,
          toggleable: true,
          groupValue: _character,
          onChanged: (String? value) {
            setState(() {});
            _character = value!;
            (_character);
          },
        ),
      );
  });
  }

  IFSCCard(String BranchName, String Address, String IfscCode) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        _ifscCodeTextEditingController.text = IfscCode;
        String response = await ApiRepository().isValidIFSC(IfscCode);
        if (response == "Not Found") {
          ("IFSC CODE WRONG");
          showIFSCErrorText = true;
          isValidIFSCCode = false;
          setState(() {});
        } else {
          showIFSCErrorText = false;
          isValidIFSCCode = true;
          //(response);
          setState(() {});
          Map valueMap = jsonDecode(response);
          String _ifscCodeR = valueMap["IFSC"];
          String _bankNameR = valueMap["BANK"];
          String _addressR = valueMap["ADDRESS"];
          openIFSCConfirmDialogBox(
              _ifscCodeR, _bankNameR, _addressR,response);
        }
      },
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Text("IFSC Code :",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: .5,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )),
                  Text("$IfscCode",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black, letterSpacing: .5, fontSize: 18),
                      )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text("$BranchName",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address :",
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            color: Colors.black,
                            letterSpacing: .5,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      )),
                  Flexible(
                    child: Text("$Address",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              color: Colors.black,
                              letterSpacing: .5,
                              fontSize: 14),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 1,
                color: Colors.black,
              ),
            ],
          )),
    );
  }

  void postDateToDB() async {
    //CALL KRA & SOLICIT FETCH
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString("PhoneNumber");
    ("We fetched phone Number");
    (phoneNumber);
    ///If only 18
    //enableDatePicker = false;
    enableBankAccountTextField = true;

    isPanValidatedSuccessfully = await ApiRepository().Digio_PanAuthentication(_panTextEditingController.text, _dateController.text);
    if(!isPanValidatedSuccessfully){
      showPANErrorText = true;
      setState(() {});
      return;
    }
    showPANErrorText = false;
    setState(() {});
    String panOwnerName = prefs.getString("PAN_OWNER_NAME");
    Fluttertoast.showToast(msg: "PAN OWNER NAME :"+panOwnerName, toastLength: Toast.LENGTH_SHORT);

    isPanValidatedSuccessfully = await ApiRepository().GetPanStatus(_panTextEditingController.text, _dateController.text);

    if (!isPanValidatedSuccessfully) {
      prefs.setString(PAN_NO_KEY, _panTextEditingController.text);
      showPANErrorText = !isPanValidatedSuccessfully;
      setState(() {});
    }


    //await ApiRepository().SolicitPANDetailsFetchALLKRALocal(_panTextEditingController.text, _dateController.text);
    enableDatePicker = false;
    enableBankAccountTextField = true;
    setState(() {});
  }

  Future<void> validateIFSC(String value) async {
    setState(() {});
    if (value.length == 11) {
      String Ifsc_pattern = "^[A-Z]{4}0[A-Z0-9]{6}\$";
      RegExp regex = new RegExp(Ifsc_pattern);
      if (!regex.hasMatch(value) || value == null) {
        //('Enter a valid IFSC CODE ');
        isValidInputForIFSC = false;
        showIFSCErrorText = true;
        setState(() {

        });
      } else {
        showIFSCErrorText = false;
        isValidInputForIFSC = true;
        setState(() {});
        //String response = await ApiRepo().isValidIFSC(value);
        String response = await ApiRepository().getIFSCDetails(value);
        if (response == "Not Found") {
          ("IFSC CODE WRONG");
          showIFSCErrorText = true;
          isValidIFSCCode = false;
          setState(() {});
        } else {
          showIFSCErrorText = false;
          isValidIFSCCode = true;
          isValidInputForIFSC = true;
          isIFSCValidatedSuccessfully = true;
          ////print(response);
          setState(() {});
          Map valueMap = jsonDecode(response);
          String _ifscCodeR = valueMap["IFSC"];
          String _bankNameR = valueMap["BANK"];
          String _addressR = valueMap["ADDRESS"];
          openIFSCConfirmDialogBox(_ifscCodeR, _bankNameR, _addressR,response);
        }
      }
    }
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    //DateTime newDate = DateTime.parse(DateFormat('dd-MM-yyyy').format(args.value));
    _dateController.text = DateFormat('dd-MM-yyyy').format(args.value);
    SchedulerBinding.instance!.addPostFrameCallback((duration) {
      setState(() {});
      postDateToDB();
    });
  }

  Widget getDateRangePicker() {
    return SfDateRangePicker(
      showNavigationArrow: true,
      view: DateRangePickerView.decade,
      showActionButtons: true,
      maxDate: DateTime(DateTime.now().year-18, DateTime.now().month, DateTime.now().day),
      minDate:DateTime(DateTime.now().year-150, DateTime.now().month, DateTime.now().day),
      initialSelectedDate:DateTime(DateTime.now().year-25, DateTime.now().month, DateTime.now().day) ,
      selectionTextStyle: TextStyle(color: Colors.white),
      selectionRadius: 15,
      selectionMode: DateRangePickerSelectionMode.single,
      onSelectionChanged: selectionChanged,
      onCancel:(){Navigator.pop(context);},
      onSubmit: (Object p1){Navigator.pop(context);},
      selectionColor: primaryColorOfApp,
      todayHighlightColor: primaryColorOfApp,
    );
  }
}
