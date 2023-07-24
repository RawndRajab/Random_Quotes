import 'package:http/http.dart' as http;
import 'dart:convert';

class RandomImg {
  // String category = "";
  Future<Map<String, dynamic>> fetchRandomImages(String category) async {
    http.Response response = await http.get(Uri.parse(
        'https://random.imagecdn.app/v1/image?width=500&height=500&category=$category&format=json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return Future.error('Something error');
    }
  }
}
