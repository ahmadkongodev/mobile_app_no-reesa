 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart'; 

import '../service.dart';

class Controller extends GetxController {
  
  final ApiService apiService = ApiService();
  static Controller get instance => Get.find();

  //variables de Moore to English
  var recordingPath = ''.obs;
  var translatedAudio = ''.obs;
  var isRecording = false.obs;
  var isPlaying = false.obs;

  //variables de English to Moore

  var recordingPath2 = ''.obs;
  var translatedAudio2 = ''.obs;
  var isRecording2 = false.obs;
  var isPlaying2 = false.obs;

  //fonctions de Moore to English
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
  void setTranslatedAudioPathToNull() => translatedAudio.value = '';

  //fonctions de English to Moore
  void setPlayingTrue2() => isPlaying2.value = true;
  void setRecordingTrue2() => isRecording2.value = true;
  void setPlayingFalse2() => isPlaying2.value = false;
  void setRecordingFalse2() => isRecording2.value = false;

  void setRecordingPath2(String audioPath) {
    // après avoir stoppé l'enregistrement, on a le lien vers le fichier audio enregistré
    recordingPath2.value = audioPath;
  }

  void setRecordingPathToNull2() => recordingPath2.value = '';
  void setTranslatedAudioPath2(String path) => translatedAudio2.value = path;
  void setTranslatedAudioPathToNull2() => translatedAudio2.value = '';

  @override
  void onInit() {
    ever(translatedAudio, (_) => playAudio(translatedAudio.value));
    ever(translatedAudio2, (_) => playAudio2(translatedAudio2.value));
    super.onInit();
  }

  Future<void>   playAudio2(String path) async {
    if (path.isNotEmpty) {
     try {
      await audioPlayer2.setFilePath(path);
      await audioPlayer2.play();
      
      setTranslatedAudioPathToNull2();
    } catch (e) {
      Controller.instance.showErrorDialog("erreur");
    }
      
    }
  }
  
  Future<void>   playAudio(String path) async {
 
    if (path.isNotEmpty) {
      await audioPlayer.setFilePath(path);
      await audioPlayer.play();
       setTranslatedAudioPathToNull();
      }
  }

  
void showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Error",
      middleText: message,
      textConfirm: "OK",
      buttonColor: Colors.red,
       onConfirm: () {
        Get.back();
      },
    );
  }
   
}

final AudioPlayer audioPlayer = AudioPlayer();
final AudioPlayer audioPlayer2 = AudioPlayer();

