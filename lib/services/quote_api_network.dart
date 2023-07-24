import 'package:http/http.dart' as http;
import 'dart:convert';

class RandomQuotes {
  Future<Map<String, dynamic>> fetchRandomQuote() async {
    http.Response response =
        await http.get(Uri.parse('https://api.quotable.io/random'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return Future.error('Something error');
    }
  }
}
