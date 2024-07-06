
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:no_reesa/controllers/controller.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart'; 
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ApiService apiService = ApiService();
  final AudioRecorder  audioRecorder = AudioRecorder();
  final AudioRecorder audioRecorder2 = AudioRecorder();

  //Functions for moore to English
  Future<void> stopRecordingAndSave() async {
    print("stop recording and save");
    // récupérer le lien de l'audio enregistré
    String? filePath = await audioRecorder.stop();
    if (filePath != null) {
      Controller.instance.setRecordingFalse();
      Controller.instance.setRecordingPath(filePath);
       
      doMooreToEnglishPrediction();
    }
  }

  Future<void> record() async {
    if (await audioRecorder.hasPermission()) {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, "recording.wav");

      await audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath,
      );
      
      Controller.instance.setRecordingTrue();
    }
  }

  Future<void> doMooreToEnglishPrediction() async {
        print("doMooreToEnglishPrediction");

    String recordingPath = Controller.instance.recordingPath.value;
    File audioFile = File(recordingPath);
    final File translatedAudioFile = await apiService.predictMooreToEnglish(audioFile);
    Controller.instance.setTranslatedAudioPath(translatedAudioFile.path); 
  }
   
  // Functions for English to moore
  
  Future<void> stopRecordingAndSave2() async {
    // récupérer le lien de l'audio enregistré
    print("in stop and record");
    String? filePath = await audioRecorder2.stop();
    if (filePath != null) {
      print("file path exist $filePath");
      Controller.instance.setRecordingFalse2();
      Controller.instance.setRecordingPath2(filePath); 
      doEnglishToMoorePrediction();
    }
  }

  Future<void> record2() async {
    if (await audioRecorder2.hasPermission()) {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, "audio_anglais.wav");

      await audioRecorder2.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath,
      );
      
      Controller.instance.setRecordingTrue2();
    }
  }

  // Future<void> doEnglishToMoorePrediction() async {
  //   String recordingPath = Controller.instance.recordingPath2.value;
  //   File audioFile = File(recordingPath);
  //   final File translatedAudioFile = await apiService.predictEnglishToMoore(audioFile);
  //   Controller.instance.setTranslatedAudioPath2(translatedAudioFile.path); 
  // } 
  Future<void> doEnglishToMoorePrediction() async {
  String recordingPath = Controller.instance.recordingPath2.value;
  print("Recording path for English to Moore: $recordingPath");

  if (recordingPath.isEmpty) {
    print("Recording path is empty.");
    return;
  }

  File audioFile = File(recordingPath);
  if (!audioFile.existsSync()) {
    print("Audio file does not exist at path: $recordingPath");
    return;
  }

  try {
    final File translatedAudioFile = await apiService.predictEnglishToMoore(audioFile);
    print("Translated audio file path: ${translatedAudioFile.path}");
    Controller.instance.setTranslatedAudioPath2(translatedAudioFile.path);
  } catch (e) {
    print("Error during English to Moore prediction: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'No-Reesa',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() =>   Controller.instance.recordingPath.value.isEmpty
                    ? const Text("No translate Found. :(")
                    : Container(
                     )),
              ],
            ),
            Obx(() => Controller.instance.isRecording.value || Controller.instance.isRecording2.value
                ? const DisplayWaves()
                : Container()),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    if (Controller.instance.isRecording.value) {
                      await stopRecordingAndSave();
                    } else {
                      await record();
                    }
                  },
                  child: Obx(() => Icon(
                        Controller.instance.isRecording.value
                            ? Icons.stop
                            : Icons.mic,
                      )),
                ),
                FloatingActionButton(
                  onPressed: () async {
                      if (Controller.instance.isRecording2.value) {
                      await stopRecordingAndSave2();
                    } else {
                      await record2();
                    }
                  },
                  backgroundColor: Colors.lightBlueAccent,
                   child: Obx(() => Icon(
                        Controller.instance.isRecording2.value
                            ? Icons.stop
                            : Icons.headphones,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayWaves extends StatelessWidget {
  const DisplayWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [Colors.lightBlueAccent, Colors.blue],
        ],
        durations: [500],
        heightPercentages: [0.5],
      ),
      size: const Size(300, 100),
      waveAmplitude: 1,
    );
  }
}