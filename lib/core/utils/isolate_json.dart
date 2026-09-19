import 'dart:convert';
import 'package:flutter/foundation.dart';

Future<dynamic> computeJsonDecode(String jsonString) async {
  return compute(jsonDecode, jsonString);
}
