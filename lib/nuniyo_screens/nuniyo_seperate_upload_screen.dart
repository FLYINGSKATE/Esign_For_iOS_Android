///Upload Document Screen
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../globals.dart';

class SeperateUploadDocumentScreen extends StatefulWidget {
  const SeperateUploadDocumentScreen({Key? key}) : super(key: key);

  @override
  _SeperateUploadDocumentScreenState createState() => _SeperateUploadDocumentScreenState();
}

class _SeperateUploadDocumentScreenState extends State<SeperateUploadDocumentScreen> {

  List<XFile>? _imageFileListPan;

  var headers = {
    'Authorization': 'Basic QUlZM0gxWFM1QVBUMkVNRkU1NFVXWjU2SVE4RlBLRlA6R083NUZXMllBWjZLUU0zRjFaU0dRVlVRQ1pQWEQ2T0Y='
  };

  bool isPanOCRVerified = false;

  set _imageFilePan(XFile? value) {
    _imageFileListPan = value == null ? null : [value];
  }

  dynamic _pickImageErrorPan;
  bool isVideo = false;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressedForPan(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        _imageFilePan = pickedFile;
        //print("we picked a file");
        //Closing the dialog Choose an option to upload the pan image
        Navigator.pop(context!);
      });
    } catch (e) {
      setState(() {
        _pickImageErrorPan = e;
      });
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Icon(Icons.ac_unit,color: Colors.black,),
        title: Text('Tech X Labs',style: GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontWeight: FontWeight.bold)),),
        backgroundColor: Color(0xffF0ECFF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().DetailsTitle('Upload Documents'),
                Center(
                  child: PANCardImagePreviewContainer()
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width/2.4,
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          showPanCardImageUploadOptionsDialog();
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Upload Image",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width/2.4,
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          _imageFileListPan = null;
                          setState(() {});
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Retry",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.grey[300],
                child: Image.memory(bytes!.buffer.asUint8List()),
              ),
            ),
          );
        },
      ),
    );
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
                            isVideo = false;
                            _onImageButtonPressedForPan(ImageSource.camera, context: context);
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
                            isVideo = false;
                            _onImageButtonPressedForPan(ImageSource.gallery, context: context);
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
  void showUploadedPanCardImageDialog() {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 400),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 600,
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22.0,10.0,0.0,10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Material(
                        color: Colors.white,
                        child: Text(
                            "Your Uploaded Pan Image",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 20,fontWeight: FontWeight.bold),)
                        ),),
                    ),
                  ),
                  SizedBox(height: 10),
                  PANCardImagePreviewContainer(),
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
                            Navigator.pop(context);
                          },
                          color: primaryColorOfApp,
                          child: Text(
                              "Close",
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
  Widget PANCardImagePreviewContainer(){
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileListPan != null) {
      //Uploading File to Database
      //PanOCRValidation(_imageFileListPan![0].path,_imageFileListPan![0]);
      return Container(
        height: MediaQuery.of(context).size.height/1.7,
        width: MediaQuery.of(context).size.width/1.1,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: kIsWeb ? Image.network(_imageFileListPan![0].path) : Image.file(File(_imageFileListPan![0].path)),
      );

    } else if (_pickImageErrorPan != null) {
      return Text(
        'Pick image error: $_pickImageErrorPan',
        textAlign: TextAlign.center,
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height/1.7,
        width: MediaQuery.of(context).size.width/1.1,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: null,
      );
    }
  }
  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  void showUploadedDigitalImageDialog() {}

}
