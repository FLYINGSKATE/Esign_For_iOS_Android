import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';


class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<bool> authenticateWithBiometrics() async {
    final LocalAuthentication localAuthentication = LocalAuthentication();
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    bool isAuthenticated = false;

    if (isBiometricSupported && canCheckBiometrics) {
      List<BiometricType> biometricTypes =
      await localAuthentication.getAvailableBiometrics();
      print(biometricTypes);

      isAuthenticated = await localAuthentication.authenticate(
        localizedReason: 'Please complete the biometrics to proceed.',
        biometricOnly: true,
        // androidAuthStrings: AndroidAuthMessages(
        //   biometricHint: 'Verify identity using biometrics',
        //   biometricRequiredTitle: 'Accessing secret vault',
        //   deviceCredentialsRequiredTitle:
        //       'Identity verification using biometrics is required to proceed to the secret vault.',
        // ),
      );
    }

    return isAuthenticated;
  }
}
