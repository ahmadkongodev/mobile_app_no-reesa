
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:no_reesa/constants.dart';
import 'package:path_provider/path_provider.dart';

import 'controllers/controller.dart';

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
        Controller.instance.showErrorDialog('erreur');
        throw Exception(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Controller.instance.showErrorDialog('erreur');
      throw Exception('Failed to get prediction: $e');
    }
  }
 
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

     
    
    var response = await request.send();

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = File('$tempPath/moore_audio.wav');
      await file.writeAsBytes(bytes);
      return file;
    } else { 
      Controller.instance.showErrorDialog('erreur');
      throw Exception('Failed to translate audio');

    }
  }
}
