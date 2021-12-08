import 'dart:convert' show utf8, base64;

import 'package:flutter/services.dart';

EncodingDecodingDemo() {
  final StringToEncode = 'https://dartpad.dartlang.org/';

  final EncodedString = base64.encode(utf8.encode(StringToEncode));
  print('base64: $EncodedString');

  final DecodedString = utf8.decode(base64.decode(EncodedString));
  print(DecodedString);
  print(StringToEncode == DecodedString);
  return EncodedString;

}

String Encode(String StringToEncode){
  final EncodedString = base64.encode(utf8.encode(StringToEncode));
  print(EncodedString);
  return EncodedString;
}

String Decode(String StringToDecode){
  final DecodedString = utf8.decode(base64.decode(StringToDecode));
  print(DecodedString);
  return DecodedString;
}


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}