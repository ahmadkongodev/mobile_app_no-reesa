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
  Future<File> predictMooreToEnglish(File audioFile) async {
    try {
      print("API");
      final request =
          http.MultipartRequest('POST', Uri.parse(predictMooreEnglishUrl));
      request.files
          .add(await http.MultipartFile.fromPath('file', audioFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final translatedAudioFile =
            File('${tempDir.path}/translated_audio.wav');
        await translatedAudioFile.writeAsBytes(responseData);
        return translatedAudioFile;
      } else {
        throw Exception(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get prediction: $e');
    }
  }

//   Future<File> predictEnglishToMoore(File audioFile) async {
//     try {
//       var request =
//           http.MultipartRequest('POST', Uri.parse(predictEnglishMooreUrl));
//       request.files
//           .add(await http.MultipartFile.fromPath('file', audioFile.path));
// // Print request details
//     print('URL: ${request.url}');
//     print('Method: ${request.method}');
//     request.headers.forEach((key, value) {
//       print('Header: $key: $value');
//     });
//     print('Files: ${request.files.map((file) => file.filename).join(', ')}');

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         var responseData = await response.stream.toBytes();
//         final tempDir = await getTemporaryDirectory();
//         final translatedFile = File('${tempDir.path}/moore_audio.wav');
//         await translatedFile.writeAsBytes(responseData);
//         return translatedFile;
//       } else {
//         throw Exception('Failed to translate audio :  ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to get prediction: e= $e');
//     }
//   }
 Future<File> predictEnglishToMoore(File audioFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(predictEnglishMooreUrl),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
      ),
    );

    print('Sending request to $predictEnglishMooreUrl /predict/english_to_moore');
    print('File: ${audioFile.path}');
    
    var response = await request.send();

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = File('$tempPath/moore_audio.wav');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response: ${await response.stream.bytesToString()}');
      throw Exception('Failed to translate audio');
    }
  }
}
