import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';

import '../globals.dart';
import '../nuniyo_custom_icons.dart';

class CommodityDocumentUploadScreen extends StatefulWidget {
  const CommodityDocumentUploadScreen({Key? key}) : super(key: key);

  @override
  _CommodityDocumentUploadScreenState createState() => _CommodityDocumentUploadScreenState();
}

class _CommodityDocumentUploadScreenState extends State<CommodityDocumentUploadScreen> {

  late FocusNode _documentNameDropDownFocusNode;

  String document_name = 'ITR STATEMENT';

  TextEditingController documentNameTextEditingController = TextEditingController();

  FilePickerResult? result;

  PlatformFile pdfPanImagefile = PlatformFile(name: "/assets/images/congratulations.png", size: 20);

  File? imageFilePan = new File("/assets/images/congratulations.png");

  bool declaration = false;

  bool showDeclarationError = false;

  bool nationality = false;

  bool showNationalityError=false;

  String headerTitle = "Select Account Type";

  bool onAccountSelected = false;

  @override
  void initState() {
    super.initState();
    //manageSteps();
    _documentNameDropDownFocusNode = FocusNode();
  }

  void _requestDocumentNameDropDownFocusNode(){
    setState(() {
      FocusScope.of(context).requestFocus(_documentNameDropDownFocusNode);
    });
  }

  @override
  void dispose() {
    _documentNameDropDownFocusNode.dispose();
  }

  Future<Null> _pickDocument(ImageSource source) async {
    //print("Lets PIck Image From Gallery");
    result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['pdf'],);
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
      Uint8List? byteList = await theNewPickedFile.readAsBytes();
      List<int> byteFormatOfFile = byteList;
      await ApiRepository().Document_Upload_FNO_Commodity(byteFormatOfFile, document_name);
      Fluttertoast.showToast(msg: "Congratulations! Your eKYC Registration is Complete!", toastLength: Toast.LENGTH_SHORT);
    }
      else{
        //No Cropping for PDF Directly View it
        Navigator.pop(context);
        setState(() {
        });
      }
    }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: WidgetHelper().NuniyoAppBar(),
        body: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: !onAccountSelected?Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0,),
                  WidgetHelper().DetailsTitle('Select Account Type'),
                  SizedBox(height: 20.0,),
                  Row(
                    children: [
                      SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: Padding(
                            padding: EdgeInsets.only(bottom:0,right: 10),
                            child:Checkbox(
                              value: this.nationality,
                              checkColor: Colors.white,
                              activeColor: primaryColorOfApp,
                              fillColor: showNationalityError?MaterialStateProperty.all(Colors.red):null,
                              onChanged: (value) {
                                setState(() {
                                  this.nationality = value!;
                                  if(nationality==true){
                                    showNationalityError = false;
                                  }
                                  //print(nationality);
                                });
                              },
                            ),)
                      ),
                      Expanded(child:Text("F & O",textAlign:TextAlign.left,style: GoogleFonts.openSans(textStyle: TextStyle(fontSize: 26,color:Colors.black, letterSpacing: .5),),),)
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      SizedBox(
                          height: 24.0,
                          width: 24.0,
                          child: Padding(
                            padding: EdgeInsets.only(bottom:0,right: 10),
                            child:Checkbox(
                              value: this.declaration,
                              checkColor: Colors.white,
                              activeColor: primaryColorOfApp,
                              fillColor: showDeclarationError?MaterialStateProperty.all(Colors.red):null,
                              onChanged: (value) {
                                setState(() {
                                  this.declaration = value!;
                                  if(declaration==true){
                                    showDeclarationError = false;
                                  }
                                  //print(declaration);
                                });
                              },
                            ),)
                      ),
                      Expanded(child:Text("Currency",textAlign:TextAlign.left,style: GoogleFonts.openSans(textStyle: TextStyle(fontSize: 26,color:Colors.black, letterSpacing: .5),),),)
                    ],
                  ),
                  SizedBox(height: 20,),
                  Container(
                    color: Colors.transparent,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 65,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () {
                        onAccountSelected = true;
                        setState(() {

                        });
                      },
                      color: primaryColorOfApp,
                      child: Text(
                          "Done",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: Colors.white,
                                letterSpacing: .5,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                ],
              ):Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0,),
                  WidgetHelper().DetailsTitle('Upload Documents'),
                  SizedBox(height: 20.0,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                    child: Container(
                      height: 75.0,
                      child: InputDecorator(
                        decoration: InputDecoration(
                            labelText: 'Select a Document',
                            labelStyle: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  fontSize: 14, letterSpacing: 0.5,
                                  color: _documentNameDropDownFocusNode.hasFocus
                                      ? primaryColorOfApp
                                      : Colors.grey,
                                )),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        //isEmpty: _currentSelectedValue == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            onTap: _requestDocumentNameDropDownFocusNode,
                            icon: Icon(NuniyoCustomIcons.down_open, size: 24.0,
                              color: _documentNameDropDownFocusNode.hasFocus
                                  ? primaryColorOfApp
                                  : Colors.black,),
                            value: document_name,
                            style: GoogleFonts.openSans(textStyle: TextStyle(
                                color: _documentNameDropDownFocusNode.hasFocus
                                    ? primaryColorOfApp
                                    : Colors.black,
                                letterSpacing: .5,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                            underline: Container(
                              color: Colors.black,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                document_name = newValue!;
                              });
                            },
                            items: <String>[
                              'ITR STATEMENT',
                              'FORM 16',
                              '6 MONTHS BANK STATEMENTS',
                              'NET WORTH CERTIFICATE',
                              '3 MONTHS SALARY SLIP',
                              'DEMAT HOLDING STATEMENT/DEMAT HOLDING REPORT'
                            ]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: SizedBox(
                                    width: 200.0,
                                    child: new Text('${value} ')
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Text("Upload a copy of your $document_name. ",
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          color: Colors.black, letterSpacing: .5, fontSize: 16),
                    ),),
                  SizedBox(height: 10.0,),
                  Text("Format Only PDF", style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        color: Colors.black, letterSpacing: .5, fontSize: 12),
                  ),),
                  SizedBox(height: 20,),
                  Container(
                    color: Colors.transparent,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 65,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () {
                        _pickDocument(ImageSource.gallery);
                      },
                      color: primaryColorOfApp,
                      child: Text(
                          "Upload",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: Colors.white,
                                letterSpacing: .5,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }
}
