 
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../service.dart';

class Controller extends GetxController {
  var recordingPath = ''.obs;
  var translatedAudio = ''.obs;
  var isRecording = false.obs;
  var isPlaying = false.obs;

  final ApiService apiService = ApiService();
  static Controller get instance => Get.find();

  void setPlayingTrue() => isPlaying.value = true;
  void setRecordingTrue() => isRecording.value = true;
  void setPlayingFalse() => isPlaying.value = false;
  void setRecordingFalse() => isRecording.value = false;

  void setRecordingPath(String filePath) {
    // après avoir stoppé l'enregistrement, on a le lien vers le fichier audio enregistré
    recordingPath.value = filePath;
  }

  void setRecordingPathToNull() => recordingPath.value = '';
  void setTranslatedAudioPath(String path) => translatedAudio.value = path;

  @override
  void onInit() {
    ever(translatedAudio, (_) => playAudio(translatedAudio.value));
    super.onInit();
  }

  Future<void> playAudio(String path) async {
    if (path.isNotEmpty) {
      await audioPlayer.setFilePath(path);
      await audioPlayer.play();
      setPlayingTrue();
    }
  }
   
}

final AudioPlayer audioPlayer = AudioPlayer();