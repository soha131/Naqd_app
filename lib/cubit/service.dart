import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'ocr_model.dart';

class ApiService {
  Future<AmountPrediction?> fetchDataFromApi(File file, BuildContext context) async {
    if (!(await file.exists())) {
      Fluttertoast.showToast(msg: "Error: File does not exist");
      return null;
    }

  final String apiUrl = "http://10.0.2.2:8000/extract-total/";


   // final String apiUrl = "http://192.168.100.4:8000/extract-total/";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(await http.MultipartFile.fromPath('file', file.path))
        ..headers.addAll({'Accept': 'application/json'});

      var streamedResponse = await request.send().timeout(Duration(seconds: 60));

      final responseBody = await streamedResponse.stream.bytesToString();
      print(responseBody);
      if (streamedResponse.statusCode == 200 && responseBody.isNotEmpty) {
        try {
          final jsonData = json.decode(responseBody);
          return AmountPrediction.fromJson(jsonData);
        } catch (e) {
          Fluttertoast.showToast(msg: "Error parsing response: $e");
          return null;
        }
      } else {
        Fluttertoast.showToast(msg: "API Error: ${streamedResponse.statusCode}");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Request failed. Check connection. Error: $e");
      return null;
    }
  }
}
