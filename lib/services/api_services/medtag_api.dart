import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MedTagApi {
  final String baseUrl = dotenv.env['BASE_URL']!;

  //Get MedTag Api
  Future getMedTag({
    required String medTagId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mtag/getMtag/$medTagId');
      var response = await http.get(
        url,
        headers: {
          "Content-type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        debugPrint("Get MedTag Post ${response.body}");
        log("Get MedTag Success");
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        log("Get MedTag Failed");
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        throw 'No MedTag found with this ID';
      } else {
        log("Get MedTag Failed");
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        throw 'Failed to get medtag, please try again later';
      }
    } catch (e) {
      log("Get MedTag Failed");
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Check if MedTag is valid and can be used
  Future checkMedTag({
    required String medTagId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mtag/mTagIdValid/$medTagId');
      var response = await http.get(
        url,
        headers: {
          "Content-type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        debugPrint("Check MedTag Post ${response.body}");
        log("Check MedTag Success");
        return jsonDecode(response.body);
      } else if (response.statusCode == 406 ||
          response.statusCode == 404 ||
          response.statusCode == 400) {
        log("Check MedTag Failed");
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        throw jsonDecode(response.body)['message'];
      } else {
        log("Check MedTag Failed");
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        throw 'Failed to check medtag, please try again later';
      }
    } catch (e) {
      log("Check MedTag Failed");
      debugPrint(e.toString());
      rethrow;
    }
  }
}
