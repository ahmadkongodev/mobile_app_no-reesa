
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:no_reesa/constants.dart';
// import 'package:path_provider/path_provider.dart';
 

// Future<File> predict_moore_to_english(File audioFile) async {
//   try {
//     // String token = await getToken();
// final request = http.MultipartRequest('POST', Uri.parse(predict_moore_english_url));
//       request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

//       final response = await request.send();

//       if (response.statusCode == 200) {
//         final responseData = await response.stream.toBytes();
//         final tempDir = await getTemporaryDirectory();
//         final filePath = '${tempDir.path}/translated_audio.wav';
//         final translatedAudioFile = File(filePath);
//         await translatedAudioFile.writeAsBytes(responseData);
//         return translatedAudioFile;
//       } else {
//         throw Exception('Failed to get prediction. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to get prediction: $e');
//     }
//   }
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:no_reesa/constants.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  
    
  Future<File> predict_moore_english_Audio(File audioFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(predict_moore_english_url));
      request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/translated_audio.wav';
        final translatedAudioFile = File(filePath);
        await translatedAudioFile.writeAsBytes(responseData);
        return translatedAudioFile;
      } else {
        throw Exception('Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get prediction: $e');
    }
  }
}
