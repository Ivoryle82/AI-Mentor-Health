import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class OpenAI {
  final String apiKey;
  OpenAI({required this.apiKey});

  Future<String?> answer(
      String question, {
        String model = 'gpt-3.5-turbo',
      }) async {

    List<Map<String, String>> messages = [
      {"role": "system", "content": "You are a mental health counselor at Lehigh University. Be sympathetic, provide support, and offer helpful advice to the student."},
      {"role": "user", "content": question}
    ];

    Map<String, dynamic> reqData = {
      "model": model,
      "messages": messages,
    };

    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 5);
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        var response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $apiKey",
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
          },
          body: jsonEncode(reqData),
        ).timeout(const Duration(seconds: 120));

        if (response.statusCode == 200) {
          Map<String, dynamic> map = json.decode(response.body);

          if (map.containsKey('choices') && map['choices'] != null) {
            List<dynamic> choices = map['choices'];
            if (choices.isNotEmpty) {
              return choices[0]['message']['content'];
            } else {
              return "No choices returned by the API.";
            }
          } else {
            return "API response did not contain 'choices' or it was null.";
          }
        } else if (response.statusCode == 429) {
          // Handle rate limiting
          String? retryAfter = response.headers['retry-after'];
          String waitTime = retryAfter != null ? "Please wait $retryAfter seconds before retrying." : "Rate limit exceeded. Please try again later.";
          
          if (attempt < maxRetries - 1) {
            attempt++;
            await Future.delayed(retryDelay);
            continue;
          } else {
            return waitTime;
          }
        } else {
          return "Request failed with status: ${response.statusCode}";
        }
      } on TimeoutException {
        return "Request to OpenAI API timed out.";
      } on SocketException {
        return "No Internet connection.";
      } catch (e) {
        return "An error occurred: $e";
      }
    }

    return null; // Return null if all retries fail
  }
}
