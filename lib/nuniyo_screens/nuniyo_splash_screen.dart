import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import 'package:sim_info/sim_info.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  ImageProvider splashScreenLogo = AssetImage("assets/images/mklogoicon.png");


  //"mobile_No": "8268405887",
  //"ip": "1232232",
  //"city": "mumbai",
  //"country": "india",
  //"state": "maharashtra",
  //"latitude": "122",
  //"longitude": "232"



  ///
  ///
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 6)).catchError((err) async {
      //print(err);
      await Geolocator.getLastKnownPosition();
    });
  }

  _getIPAddress() async {
    try {
      /// Initialize Ip Address
      var ipAddress = IpAddress(type: RequestType.json);

      /// Get the IpAddress based on requestType.
      dynamic data = await ipAddress.getIpAddress();
      //print("||||||||||||AAAPKA IP ADDRESS HAI :-"+data.toString());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("IP_ADDRESS", data.toString());

      //print(data.toString());
    } on IpAddressException catch (exception) {
      /// Handle the exception.
      //print(exception.message);
    }
    // e.g. 113.139.104.65 or ""
  }

  _getSimDeviceInfo() async {
    String allowsVOIP = await SimInfo.getAllowsVOIP;
    String carrierName = await SimInfo.getCarrierName;
    String isoCountryCode = await SimInfo.getIsoCountryCode;
    String mobileCountryCode = await SimInfo.getMobileCountryCode;
    String mobileNetworkCode = await SimInfo.getMobileNetworkCode;

    //print("Allows Voip"+allowsVOIP);
    //print("carrier name"+carrierName);
    //print("isoCountryCode"+isoCountryCode);
    //print("mobileCountryCode"+mobileCountryCode);
    //print("mobileNetworkCode"+mobileNetworkCode);
  }

  _getDeviceInfo(){}

  _getCurrentLocation() async {
    //await Future.delayed(Duration(seconds: 100));
    Position _currentPosition = await _determinePosition();
    //print("CURRENT POSITION :LATITUDE "+_currentPosition.latitude.toString() + "LONGITUDE : "+_currentPosition.longitude.toString());
    // this will get the coordinates from the lat-long using Geocoder Coordinates



    final coordinates = Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    //showToastNotification(_currentPosition.latitude.toString());
    //showToastNotification("CURRENT POSITION :LATITUDE "+_currentPosition.latitude.toString() + "LONGITUDE : "+_currentPosition.longitude.toString());

    // this fetches multiple address, but you need to get the first address by doing the following two codes
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    //print(first.countryName);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("COUNTRY", first.countryName);
    prefs.setString("STATE",first.adminArea);
    prefs.setString("CITY",first.locality);
    prefs.setString("LONGITUDE", _currentPosition.longitude.toString());
    prefs.setString("LATITUDE", _currentPosition.latitude.toString());
    await Future.delayed(const Duration(seconds: 2), (){});
    //showToastNotification("Current Location : "+first.countryName+"-SUBADMIN AREA -"+first.subAdminArea+"-locality"+first.locality+"|"+first.subLocality+","+first.postalCode+"AADMIN AREA"+first.adminArea);
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => loadMobileScreen());
    if(!kIsWeb){
      _askForPermissions();
      _getSimDeviceInfo();
      //print("GETTTTTIING DEVICE INFO");
      //print(_deviceData.values);
      //print("Upar Dekh Device Info");
      _getIPAddress();
      _getCurrentLocation();

      //EMULATOR
      //_getBioMetricsAuthentication();
    }
    else{
      _askForPermissions();
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(splashScreenLogo, context);
    return Material(child:Container(
      decoration: BoxDecoration(
          color: Colors.white
        ),
        child:Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                height: 80.0,
                width: 80.0,
                decoration: new BoxDecoration(
                  image: DecorationImage(
                    image: splashScreenLogo,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Text('Mangal Keshav',style: GoogleFonts.openSans(fontSize: 32,textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontWeight: FontWeight.bold))),
          ],
        ))
    ));
  }

  /*showToastNotification(String currentLocation) {
    Fluttertoast.showToast(
        msg: currentLocation,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }*/



  /*void _getBioMetricsAuthentication() async {
    bool isAuthenticated = await Authentication.authenticateWithBiometrics();
    if (isAuthenticated) {
      WidgetsBinding.instance!.addPostFrameCallback((_){
        Navigator.pushNamed(context,'Mobile');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error authenticating using Biometrics.',
        ),
      );
    }
  }*/

  Future<void> _askForPermissions() async {
    ////print("asking for permissions");
    if (await Permission.storage.request().isGranted) {
      ////print("Permitted to use Local Storage");
    }
    else{
      //print("Don't Deny let us use local storage");
    }
    if (await Permission.location.request().isGranted) {
      //print("Permitted to use Locations Storage");
    }
    else{
      //print("Don't Deny Locations");
    }
    if (await Permission.camera.request().isGranted) {
      //print("Permitted to use Camera");
    }
    else{
      //print("Don't Deny Camera");
    }
    if (await Permission.microphone.request().isGranted) {
      //print("Permitted to use Microphone");
    }
    else{
      //print("Don't Deny Microphone");
    }
    /*if (await Permission.location.isDenied) {
      showToastNotification("Please Give Location Access to the App");
      Geolocator.openLocationSettings();
    }*/

  }

  Future<void> loadMobileScreen() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushNamed(context,'Mobile');
  }
}