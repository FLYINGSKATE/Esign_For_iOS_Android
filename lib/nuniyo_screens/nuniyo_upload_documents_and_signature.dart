///Upload Document Screen
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/utils/encode_decode.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../ApiRepository/api_repository.dart';
import '../globals.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({Key? key}) : super(key: key);

  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {

  //IFSC VARIABLE
  ScrollController _scrollController = ScrollController();

  bool enableBankAccountTextField = true;

  bool enableIFSCCodeTextField = true;

  Map IFSCMapList = {};

  bool isValidBankAccount = false;

  bool showBankAccountNumberErrorText= false;



  bool showBranchNameErrorText = false;
  bool showBranchLocationErrorText = false;

  TextEditingController _bankTextEditingController= TextEditingController();


  TextEditingController _branchLocationTextEditingController= TextEditingController();
  TextEditingController _branchNameTextEditingController= TextEditingController();
  TextEditingController _ifscCodeDialogTextEditingController= TextEditingController();


  bool isValidInputForBank= false;
  bool isBankValidatedSuccessfully= false;

  late FocusNode _bankTextFieldFocusNode,_ifscTextFieldFocusNode,_IFSCCode2TextFieldFocusNode,_branchNameTextFieldFocusNode;

  bool isIFSCValidatedSuccessfully = false;

  TextEditingController _ifscCodeTextEditingController = TextEditingController();

  bool showIFSCErrorText = false;

  bool isValidIFSCCode = false;

  bool isValidInputForIFSC = false;

  bool showIFSCSearchResults = false;

  late FocusNode _branchLocationTextFieldFocusNode;

  String branchNameErrorText = "";

  String branchLocationErrorText = "";

  TextEditingController _dateController = TextEditingController();
  //IFSC Variable


  bool isPanOCRVerified = false;

  bool isAadharOCRVerified = false;

  bool showPanCardImageBox = false;

  bool showDigitalPadBox = false;

  File? imageFilePan = new File("/assets/images/congratulations.png");

  bool tempPanUploaded = false;
  bool tempDigitalPadUploaded = false;

  File? imageFileDigitalSignature = new File("/assets/images/congratulations.png");

  FilePickerResult? result;
  PlatformFile pdfPanImagefile = PlatformFile(name: "/assets/images/congratulations.png", size: 20);
  PlatformFile pdfPanDigitalSignaturefile = PlatformFile(name: "/assets/images/congratulations.png", size: 20);

  var drawnDigitalSignatureImage = null;

  bool showDrawnDigitalSignatureImage = false;

  bool isPANImageFromCamera = false;
  bool isDigitalSignatureFromCamera = false;

  bool onceProceedClicked = false;

  bool isKRAVerified = true;

  String digitalSignatureUploadApiMessage = "false";
  String panUploadApiMessage = "false";


  bool nameMatched = false;

  Future<Null> _pickImageForPan(ImageSource source) async {
    if(source == ImageSource.gallery){
      //print("Lets PIck Image From Gallery");
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['pdf','png','jpg','jpeg'],);
        //allowedExtensions: ['jpg'],);
      if(result != null) {
        ///FILE SIZE
        File theNewPickedFile = File(result!.files.first.path.toString());
        int sizeInBytes = theNewPickedFile.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        //print("Your File Size is : "+sizeInMb.toString());
        if(sizeInMb > 2){
          // This file is Longer the
          //print("Your file is greater than 2MB");
          ///
          Navigator.pop(context);
          Flushbar(
            flushbarPosition: FlushbarPosition.BOTTOM,
            icon: Icon(Icons.error,color: Colors.red,),
            title:  "Error",
            duration:  Duration(seconds: 3),
            messageText: Text(
              "File Size Cannot Be Greater than 2MB",
              style: TextStyle(color: Colors.red, letterSpacing: 0.5),
            ),
          )..show(context);
          return;
        }

        pdfPanImagefile = result!.files.first;
        //print(pdfPanImagefile.name);
        //print(pdfPanImagefile.bytes);
        //print(pdfPanImagefile.size);
        //print(pdfPanImagefile.extension);
        //print(pdfPanImagefile.path);

        if(pdfPanImagefile.extension != 'pdf'){
          imageFilePan = File(pdfPanImagefile.path.toString());
          if (imageFilePan != null) {
            setState(() {
              isPANImageFromCamera  = false;
              //print("SOME ISSUES HERE??????GALLL");
              Navigator.pop(context);
              _cropImageForPan();
            });
          }
        }
        else{
          //No Cropping for PDF Directly View it
          Navigator.pop(context);
          isPANImageFromCamera = false;
          tempPanUploaded = true;
          setState(() {
          });
        }


      } else {
        // User canceled the picker
      }
    }
    else{
      ///Chosen Camera to Upload File
      final pickedImage = await ImagePicker().pickImage(source: source);
      imageFilePan = pickedImage != null ? File(pickedImage.path) : null;
      if (imageFilePan != null) {
        setState(() {
          isPANImageFromCamera = true;
          //print("SOME ISSUES HERE??????");
          Navigator.pop(context);
          _cropImageForPan();
        });
      }
    }
  }

  Future<Null> _pickImageForDigitalSignature(ImageSource source) async {
    if(source == ImageSource.gallery){
      //print("Lets PIck Image From Gallery");
      result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['pdf','png','jpg','jpeg'],);
      //allowedExtensions: ['jpg'],);
      if(result != null) {
        ///FILE SIZE
        File theNewPickedFile = File(result!.files.first.path.toString());
        int sizeInBytes = theNewPickedFile.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);
        //print("Your File Size is : "+sizeInMb.toString());
        if(sizeInMb > 2){
          // This file is Longer the
          //print("Your file is greater than 2MB");
          Navigator.pop(context);
          Flushbar(
            flushbarPosition: FlushbarPosition.BOTTOM,
            icon: Icon(Icons.error,color: Colors.red,),
            title:  "Error",
            duration:  Duration(seconds: 3),
            messageText: Text(
              "File Size Cannot Be Greater than 2MB",
              style: TextStyle(color: Colors.red, letterSpacing: 0.5),
            ),
          )..show(context);
          return;
        }
        pdfPanDigitalSignaturefile = result!.files.first;
        //print(pdfPanDigitalSignaturefile.name);
        //print(pdfPanDigitalSignaturefile.bytes);
        //print(pdfPanDigitalSignaturefile.size);
        //print(pdfPanDigitalSignaturefile.extension);
        //print(pdfPanDigitalSignaturefile.path);

        if(pdfPanDigitalSignaturefile.extension != 'pdf'){
          imageFileDigitalSignature = File(pdfPanDigitalSignaturefile.path.toString());
          if (imageFileDigitalSignature != null) {
            setState(() {
              Navigator.pop(context);
              _cropImageForDigitalSignature();
            });
          }
        }
        else{
          //No Cropping for PDF Directly View it
          isDigitalSignatureFromCamera = false;
          showDrawnDigitalSignatureImage = false;
          Navigator.pop(context);
          tempDigitalPadUploaded = true;
          setState(() {
          });
        }
      } else {
        // User canceled the picker
      }
    }
    else{
      ///Chosen Camera to Upload File
      final pickedImage = await ImagePicker().pickImage(source: source);
      imageFileDigitalSignature = pickedImage != null ? File(pickedImage.path) : null;
      if (imageFileDigitalSignature != null) {
        setState(() {
          isDigitalSignatureFromCamera = true;
          showDrawnDigitalSignatureImage = false;
          Navigator.pop(context);
          _cropImageForDigitalSignature();
        });
      }
    }

  }

  @override
  void deactivate() {
    super.deactivate();
  }


  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    CheckIsKraVerified();
    ///
    /// Penny Drop
    _bankTextFieldFocusNode = FocusNode();
    _ifscTextFieldFocusNode = FocusNode();
    _IFSCCode2TextFieldFocusNode = FocusNode();
    _branchNameTextFieldFocusNode = FocusNode();
    _branchLocationTextFieldFocusNode=FocusNode();
    ///
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
    return WillPopScope(onWillPop: _onWillPop ,child:Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: WidgetHelper().NuniyoAppBar(),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Visibility(child:IFSCFields() ,visible: !nameMatched,),
                WidgetHelper().DetailsTitle('Upload Documents'),
                Visibility(child: PanBox(),visible: !isKRAVerified,),
                Text("Signature",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 22,fontWeight: FontWeight.bold),
                ),),
                SizedBox(height: 20,),
                Text("Please sign on a blank paper with a pen & upload a photo of the same.",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 10,),
                Text("You can also sign on the digital pad.",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          showDigitalPadDialog();
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Digital Pad",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          showDigitalSignatureImageUploadOptionsDialog();
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Upload Image",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(visible: showDigitalPadBox,child: SizedBox(height: 20,)),
                Visibility(
                  visible: showDigitalPadBox,
                  child: Center(child:populateDigitalPadImageBox(),),
                ),
                SizedBox(height: 30.0,),
                Visibility(
                  visible: tempDigitalPadUploaded,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed:(){}, icon: Icon(Icons.check_circle,size: 36.0,color: Colors.green,)),
                      SizedBox(width: 30,),
                      IconButton(onPressed:(){
                        showDigitalPadBox = !showDigitalPadBox;
                        setState(() {});
                      }, icon: Icon(Icons.remove_red_eye_outlined,size: 36.0,color: primaryColorOfApp,)),
                      SizedBox(width: 30,),
                      IconButton(onPressed:(){
                        tempDigitalPadUploaded = false;
                        showDigitalPadBox = false;
                        setState(() {});
                      }, icon: Icon(Icons.delete,size: 36.0,color: Colors.red,)),
                    ],
                  ),),
                SizedBox(height: 30.0,),
                SizedBox(height: 10,),
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
                    onPressed:(!onceProceedClicked&&(tempPanUploaded&&tempDigitalPadUploaded)&&(isBankValidatedSuccessfully&&isIFSCValidatedSuccessfully))?() async {
                        onceProceedClicked = true;
                        bool panUploaded = false;
                        bool isAPanImage = false;
                        if(isKRAVerified){
                          panUploaded = true;
                          isAPanImage = true;
                        }
                        setState(() {});
                        if(imageFilePan.toString()!='File: \'/assets/images/congratulations.png\''&&imageFilePan!=null&&!isKRAVerified){
                          //CALL APIS TO UPLOAD
                          //print("Uploading Image Format of Pan to API");
                          ///Upload APi
                          ///
                          Uint8List byteFormatOfFile = await imageFilePan!.readAsBytes();
                          String fileExtension = imageFilePan!.path.split('/').last;
                          //print(fileExtension);

                          //Compress and send
                          var result = await FlutterImageCompress.compressWithList(
                            byteFormatOfFile,
                            quality: 50,
                          );
                          //print(byteFormatOfFile.length);
                          //print(result.length);
                          ////////
                          panUploadApiMessage = await ApiRepository().DocumentUploadPAN(result,fileExtension);
                          if(panUploadApiMessage=="true"){
                            isAPanImage = true;
                          }
                          else{
                            isAPanImage = false;
                          }

                          panUploaded = true;
                          ///Upload APi
                        }
                        if(imageFileDigitalSignature.toString()!='File: \'/assets/images/congratulations.png\'' && imageFileDigitalSignature!=null){
                          //print("Uploading Image Format of Digital Signature");

                          List<int> byteFormatOfFile = await imageFileDigitalSignature!.readAsBytes();
                          String fileExtension = imageFileDigitalSignature!.path.split('/').last;
                          //print(fileExtension);
                          await ApiRepository().DocumentUploadDigitalSignature(byteFormatOfFile,fileExtension);
                        }
                        if(pdfPanImagefile.name!="/assets/images/congratulations.png"&&!panUploaded&&!isKRAVerified){
                          //print("Uploading PDF Format of PAN IMAGE FILE");
                          Uint8List? byteList = pdfPanImagefile.bytes;
                          if(byteList!=null){
                            List<int> byteFormatOfFile = byteList;
                            if(await ApiRepository().DocumentUploadPAN(byteFormatOfFile,pdfPanImagefile.extension.toString()) =="true"){
                              isAPanImage = true ;
                            }
                            else{
                              isAPanImage = false;
                            }
                          }
                          panUploaded = true;
                          //List<int>? byteFormatOfFile =await pdfPanImagefile.bytes!.toList(growable: true);

                        }
                        if(pdfPanDigitalSignaturefile.name!="/assets/images/congratulations.png"){
                          //print("Uploading PDF Format of Digital Signature");

                          Uint8List? byteList = pdfPanDigitalSignaturefile.bytes;
                          if(byteList!=null){
                            List<int> byteFormatOfFile = byteList;
                            digitalSignatureUploadApiMessage = await ApiRepository().DocumentUploadDigitalSignature(byteFormatOfFile,pdfPanDigitalSignaturefile.extension.toString());
                          }
                        }
                        if(drawnDigitalSignatureImage!=null){
                          //print("Uploading Drawn Digital Signature");
                          List<int> byteFormatOfFile = drawnDigitalSignatureImage!.buffer.asUint8List();
                          digitalSignatureUploadApiMessage = await ApiRepository().DocumentUploadDigitalSignature(byteFormatOfFile,"jpg");
                        }
                        if(digitalSignatureUploadApiMessage!="true"){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.black,
                            content: Text(
                              "$digitalSignatureUploadApiMessage",
                              style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
                            ),
                          ));
                          onceProceedClicked = false;
                          setState(() {

                          });
                          return;
                        }
                        else if(!panUploaded){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.black,
                            content: Text(
                              "PAN Not Uploaded",
                              style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
                            ),
                          ));
                          onceProceedClicked = false;
                          setState(() {
                          });
                          return;
                        }
                        else if(!isAPanImage){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.black,
                            content: Text(
                              "Please Upload A Valid PAN!",
                              style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
                            ),
                          ));
                          onceProceedClicked = false;
                          setState(() {});
                          return;
                        }

                        ///Update Stage ID Here
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await ApiRepository().UpdateStage_Id();
                        String ThisStepId = prefs.getString(STAGE_KEY);
                        //print("YOU LEFT ON THIS PAGE LAST TIME"+ThisStepId);
                        Navigator.pushNamed(context,ThisStepId);
                    }:null,
                    color: primaryColorOfApp,
                    child: !onceProceedClicked?Text(
                        "Proceed",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                    ):Row(
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),)
    );
  }

  //Digital Pad Methods
  void showDigitalPadDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 420,
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22.0,10.0,0.0,10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.white,
                        child: Text(
                            "Upload Signature",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 20,fontWeight: FontWeight.bold),)
                        ),),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                          child: SfSignaturePad(
                              key: signatureGlobalKey,
                              backgroundColor: Colors.white,
                              strokeColor: Colors.black,
                              minimumStrokeWidth: 1.0,
                              maximumStrokeWidth: 4.0),
                          decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)))),
                  SizedBox(height: 10),
                  Row(children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          _handleSaveButtonPressed();
                          setState(() {
                          });
                          ///
                          Navigator.pop(context);
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Upload",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          _handleClearButtonPressed();
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Clear",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                  ], mainAxisAlignment: MainAxisAlignment.spaceEvenly)
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center),
            margin: EdgeInsets.only(bottom: 20, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
  }

  void _handleSaveButtonPressed() async {
    final data = await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);

    drawnDigitalSignatureImage = bytes;
    showDrawnDigitalSignatureImage = true;
    //print(data);
    tempDigitalPadUploaded  = true;
    setState(() {
      drawnDigitalSignatureImage = bytes;
    });
  }

  ///PAN CARD METHODS
  void showPanCardImageUploadOptionsDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 250,
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22.0,10.0,0.0,10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Material(
                        color: Colors.white,
                        child: Text(
                            "Choose An Option!",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 20,fontWeight: FontWeight.bold),)
                        ),),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.5,
                        color: Colors.transparent,
                        height: 60,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onPressed: () {
                            _pickImageForPan(ImageSource.camera);
                          },
                          color: primaryColorOfApp,
                          child: Text(
                              "Open Camera",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.5,
                        color: Colors.transparent,
                        height: 60,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onPressed: () {
                            _pickImageForPan(ImageSource.gallery);
                          },
                          color: primaryColorOfApp,
                          child: Text(
                              "Upload From Gallery",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                          ),
                        ),
                      ),
                    ),
                  ], mainAxisAlignment: MainAxisAlignment.spaceEvenly)
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center),
            margin: EdgeInsets.only(bottom: 20, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void showDigitalSignatureImageUploadOptionsDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 250,
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22.0,10.0,0.0,10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Material(
                        color: Colors.white,
                        child: Text(
                            "Choose An Option!",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 20,fontWeight: FontWeight.bold),)
                        ),),
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.5,
                        color: Colors.transparent,
                        height: 60,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onPressed: () {
                            _pickImageForDigitalSignature(ImageSource.camera);
                          },
                          color: primaryColorOfApp,
                          child: Text(
                              "Open Camera",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.5,
                        color: Colors.transparent,
                        height: 60,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onPressed: () {
                            _pickImageForDigitalSignature(ImageSource.gallery);
                          },
                          color: primaryColorOfApp,
                          child: Text(
                              "Upload From Gallery",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                          ),
                        ),
                      ),
                    ),
                  ], mainAxisAlignment: MainAxisAlignment.spaceEvenly)
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center),
            margin: EdgeInsets.only(bottom: 20, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  populatePanCardImageBox() {
    if (imageFilePan != null) {
      //Uploading File to Database
      //PanOCRValidation(_imageFilePanListPan![0].path,_imageFilePanListPan![0]);
      return Container(
        height: MediaQuery.of(context).size.height/6,
        width: MediaQuery.of(context).size.width/3,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        child: pdfPanImagefile.extension == 'pdf' ? SfPdfViewer.file(File(pdfPanImagefile.path.toString())) : Image.file(File(imageFilePan!.path)),
      );

    }  else {
      return Container(
        height: MediaQuery.of(context).size.height/6,
        width: MediaQuery.of(context).size.width/3,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        child: null,
      );
    }
  }

  populateDigitalPadImageBox() {
    if (imageFileDigitalSignature != null) {
      //Uploading File to Database
      //PanOCRValidation(_imageFilePanListPan![0].path,_imageFilePanListPan![0]);
      return Container(
        height: MediaQuery.of(context).size.height/6,
        width: MediaQuery.of(context).size.width/3,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        child: showDrawnDigitalSignatureImage ? Image.memory(drawnDigitalSignatureImage!.buffer.asUint8List()):pdfPanDigitalSignaturefile.extension == 'pdf' ? SfPdfViewer.file(File(pdfPanDigitalSignaturefile.path.toString())) : Image.file(File(imageFileDigitalSignature!.path)),
      );
    }  else {
      return Container(
        height: MediaQuery.of(context).size.height/6,
        width: MediaQuery.of(context).size.width/3,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(0))
        ),
        child: null,
      );
    }
  }



  Future<Null> _cropImageForPan() async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFilePan!.path,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: primaryColorOfApp,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      ///FILE SIZE
      int sizeInBytes = croppedFile.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      //print("Your File Size is : "+sizeInMb.toString());
      if(sizeInMb > 2){
        // This file is Longer the
        //print("Your file is greater than 2MB");
        //ISSUE : - That's why removed Navigator.pop(context);
        Flushbar(
          flushbarPosition: FlushbarPosition.BOTTOM,
          icon: Icon(Icons.error,color: Colors.red,),
          title:  "Error",
          duration:  Duration(seconds: 3),
          messageText: Text(
            "File Size Cannot Be Greater than 2MB",
            style: TextStyle(color: Colors.red, letterSpacing: 0.5),
          ),
        )..show(context);
        ///Delete the files from picker as well
        imageFilePan = null;
        croppedFile = null;
        return;
      }
      imageFilePan = croppedFile;
      tempPanUploaded = true;
      //Navigator.pop(context);
      setState(() {

      });
    }
  }

  Future<Null> _cropImageForDigitalSignature() async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFileDigitalSignature!.path,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: primaryColorOfApp,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {

      ///FILE SIZE
      int sizeInBytes = croppedFile.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      //print("Your File Size is : "+sizeInMb.toString());
      if(sizeInMb > 2){
        // This file is Longer the
        //print("Your file is greater than 2MB");
        //Navigator.pop(context);
        Flushbar(
          flushbarPosition: FlushbarPosition.BOTTOM,
          icon: Icon(Icons.error,color: Colors.red,),
          title:  "Error",
          duration:  Duration(seconds: 3),
          messageText: Text(
            "File Size Cannot Be Greater than 2MB",
            style: TextStyle(color: Colors.red, letterSpacing: 0.5),
          ),
        )..show(context);
        imageFileDigitalSignature = null;
        croppedFile = null;
        return;
      }
      /////
      imageFileDigitalSignature = croppedFile;
      showDrawnDigitalSignatureImage = false;
      tempDigitalPadUploaded  = true;
      setState(() {
      });
    }
  }

  PanBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Copy of PAN",style: GoogleFonts.openSans(
          textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 22,fontWeight: FontWeight.bold),
        ),),
        SizedBox(height: 20,),
        Text("Upload a signed copy of your PAN Card.",style: GoogleFonts.openSans(
          textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
        ),),
        Text("Format PNG,JPG,PDF",style: GoogleFonts.openSans(
          textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 12),
        ),),
        SizedBox(height: 20,),
        Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: 65,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            onPressed: () {
              showPanCardImageUploadOptionsDialog();
            },
            color: primaryColorOfApp,
            child: Text(
                "Upload",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
            ),
          ),
        ),
        ///Small View Container
        Visibility(visible: showPanCardImageBox,child: SizedBox(height: 20,)),
        Visibility(
          visible: showPanCardImageBox,
          child: Center(
            child:populatePanCardImageBox(),
          ),
        ),
        SizedBox(height: 30.0,),
        Visibility(
          visible: tempPanUploaded,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed:() async {
                if (imageFilePan != null) {
                  //Uploading File to Database
                  //isPanOCRVerified = await ApiRepo().PanOCRValidation(imageFilePan!.path,imageFilePan);
                }
              }, icon: Icon(Icons.check_circle,size: 36.0,color: Colors.green,)),
              SizedBox(width: 30,),
              IconButton(onPressed:(){ showPanCardImageBox = !showPanCardImageBox;setState(() {
              });}, icon: Icon(Icons.remove_red_eye_outlined,size: 36.0,color: primaryColorOfApp,)),
              SizedBox(width: 30,),
              IconButton(onPressed:(){
                imageFilePan = null;
                tempPanUploaded = false;
                setState(() {});
                showPanCardImageBox = false;
              }, icon: Icon(Icons.delete,size: 36.0,color: Colors.red,)),
            ],
          ),),
        SizedBox(height: 30.0,),
        Divider(thickness: 2.0,),
      ],
    );
  }

  Future<void> CheckIsKraVerified() async {
    Map valueMap = await ApiRepository().DocumentUploadCheck();

    if(valueMap["res_Output"][0]["is_Kra_Verified"]==0){
      isKRAVerified = false;
    }

    if(valueMap["res_Output"][0]["is_Bank_Name_As_Per_PAN"]>=1){
      nameMatched = true;
      isIFSCValidatedSuccessfully = true;
      isBankValidatedSuccessfully = true;
    }

    if(isKRAVerified){
      tempPanUploaded = true;
      //print("bdk6tssl6ysx6l");
      //tempDigitalPadUploaded = true;
    }
    nameMatched = true;
    isIFSCValidatedSuccessfully = true;
    isBankValidatedSuccessfully = true;
    setState(() {});
    await ApiRepository().Create_Aadhaar_From_XML();
  }

  IFSCFields() {
    return Expanded(child:Column(
      children: [
        Text("Your Bank Name & PAN Name are mismatched",style: GoogleFonts.openSans(
          textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 22,fontWeight: FontWeight.bold),
        ),),
        SizedBox(height: 20,),
        Flexible(child: TextField(
          enabled: enableBankAccountTextField ,
          textCapitalization: TextCapitalization.characters,
          controller: _bankTextEditingController,
          onChanged: (value) async {
            if(value.length>18 || value.length>9){
              //print("Verifying Bank Account");
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
          inputFormatters: [UpperCaseTextFormatter(),],
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
    ));
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

  Future<void> validateIFSC(String value) async {
    setState(() {});
    if (value.length == 11) {
      String Ifsc_pattern = "^[A-Z]{4}0[A-Z0-9]{6}\$";
      RegExp regex = new RegExp(Ifsc_pattern);
      if (!regex.hasMatch(value) || value == null) {
        //print('Enter a valid IFSC CODE ');
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
          //print("IFSC CODE WRONG");
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
                                Navigator.pop(context);

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

  IFSCCard(String BranchName, String Address, String IfscCode) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        _ifscCodeTextEditingController.text = IfscCode;
        String response = await ApiRepository().isValidIFSC(IfscCode);
        if (response == "Not Found") {
          //print("IFSC CODE WRONG");
          showIFSCErrorText = true;
          isValidIFSCCode = false;
          setState(() {});
        } else {
          showIFSCErrorText = false;
          isValidIFSCCode = true;
          ////print(response);
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

}
