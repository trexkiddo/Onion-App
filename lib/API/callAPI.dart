//API Calls

//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Standard post request code to simplify post API calls
Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> payload) async {
  String apiUrl = 'http://group30.xyz/api/$endpoint';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      // Handle success
      return jsonDecode(response.body);
    } else {
      // Handle different status codes
      throw Exception('Failed with status code ${response.statusCode}');
    }
  } catch (error) {
  return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

//login
Future<Map<String,dynamic>> loginAPI(Map<String, dynamic> payload) async {
  return postRequest('login', payload);
}

//signup
Future<Map<String,dynamic>> signupAPI(Map<String, dynamic> payload) async {
  return postRequest('signup', payload);
}

//updatePantry
Future<Map<String,dynamic>> updatePantryAPI(Map<String, dynamic> payload) async {
  return postRequest('updatePantry', payload);
}

//Add allergen
Future<Map<String,dynamic>> addAllergenAPI(Map<String, dynamic> payload) async {
  return postRequest('addAllergen', payload);
}

//delete allergen
Future<Map<String,dynamic>> deleteAllergenAPI(Map<String, dynamic> payload) async {
  String apiUrl = 'http://group30.xyz/api/removeAllergen';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return jsonDecode(response.body);
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

//fetch favorites
Future<Map<String,dynamic>> fetchFavoritesAPI(Map<String, dynamic> payload) async {
  return postRequest('fetchFavorites', payload);
}

//add favorite
Future<Map<String,dynamic>> addFavoriteAPI(Map<String, dynamic> payload) async {
  return postRequest('addfavorite', payload);
}

//delete favorite TODO: Still need to do delete favorite
Future<Map<String,dynamic>> deleteFavoriteAPI(Map<String, dynamic> payload) async {
  String apiUrl = 'http://group30.xyz/api/removefavorite';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return jsonDecode(response.body);
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

Future<Map<String,dynamic>> getRecipeInfoAPI(int id) async {
  final String apiUrl = 'group30.xyz';
  final String endpoint = '/api/getRecipeInfo';
  
  final Map<String, dynamic> queryParams = {
    'RecipeID': id.toString(),
  };

  //Builds the URI with parameters
  final Uri url = Uri.http(apiUrl, endpoint, queryParams);

  try{
    final response = await http.get(url);

    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if(response.statusCode == 200){
      //Handle success
      return jsonDecode(response.body);
    } else{
      // Handle different status codes
      throw Exception('Failed with status code ${response.statusCode}');
    }
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

//passwordResetRequest
Future<Map<String,dynamic>> requestPasswordResetAPI(Map<String, dynamic> payload) async {
  //return postRequest('requestPasswordReset', payload);

  String apiUrl = 'http://group30.xyz/api/requestPasswordReset';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return jsonDecode(response.body);
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }

}

//validatePasswordReset
Future<Map<String,dynamic>> validatePasswordResetAPI(Map<String, dynamic> payload) async{
  //return postRequest('validatePasswordReset', payload);

  String apiUrl = 'http://group30.xyz/api/validatePasswordReset';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return jsonDecode(response.body);
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

//passwordResetRequest
Future<Map<String,dynamic>> requestEmailVerificationAPI(Map<String, dynamic> payload) async {
  //return postRequest('requestPasswordReset', payload);

  String apiUrl = 'http://group30.xyz/api/requestEmailVerification';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return jsonDecode(response.body);
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }

}

//validatePasswordReset
Future<Map<String,dynamic>> validateEmailVerificationAPI(Map<String, dynamic> payload) async{
  //return postRequest('validatePasswordReset', payload);

  String apiUrl = 'http://group30.xyz/api/validateEmailVerification';
  final url = Uri.parse(apiUrl);
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return jsonDecode(response.body);
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

//search 
Future<Map<String,dynamic>> searchAPI(String query, {List<String>? allergens,Map<String,String>? additionalParams}) async {
  final String apiUrl = 'group30.xyz';
  final String endpoint = '/api/searchRecipe';

  //Map of query parameters
  final Map<String, String> queryParams = {
    'q': query,
    if (allergens != null && allergens.isNotEmpty) 'allergens': allergens.join(','),
    ...?additionalParams,
  };

  //Builds the URI with parameters
  final Uri url = Uri.http(apiUrl, endpoint, queryParams);

  try{
    final response = await http.get(url);

    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if(response.statusCode == 200){
      //Handle success
      return jsonDecode(response.body);
    } else{
      // Handle different status codes
      throw Exception('Failed with status code ${response.statusCode}');
    }
  } catch (error) {
    return {
      'ERROR': 'An unexpected error occurred: $error'
    };
  }
}

//search by pantry
Future<List<dynamic>> searchPantryAPI(List<String> pantry, List<String> allergens) async {
  final String apiUrl = 'group30.xyz';
  final String endpoint = '/api/searchPantry';

  //Map of query parameters
  final Map<String,String> queryParams = {
    'ingredients': pantry.join(','),
    'allergens': allergens.join(','),
  };

  //Builds the URI with parameters
  final Uri url = Uri.http(apiUrl, endpoint, queryParams);

  try{
    final response = await http.get(url);

    // Log the response status and body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if(response.statusCode == 200){
      //Handle success
      return jsonDecode(response.body);
    } else{
      // Handle different status codes
      throw Exception('Failed with status code ${response.statusCode}');
    }

  }catch (error) {
    return [
      'ERROR'
    ];
  }
}