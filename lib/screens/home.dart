
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
  final AudioRecorder audioRecorder = AudioRecorder();

  Future<void> stopRecordingAndSave() async {
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
    String recordingPath = Controller.instance.recordingPath.value;
    File audioFile = File(recordingPath);
    final File translatedAudioFile = await apiService.predict_moore_english_Audio(audioFile);
    Controller.instance.setTranslatedAudioPath(translatedAudioFile.path); 
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
                Obx(() => Controller.instance.translatedAudio.value.isEmpty
                    ? const Text("No translate Found. :(")
                    : Container()),
              ],
            ),
            Obx(() => Controller.instance.isRecording.value
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
                    await doMooreToEnglishPrediction();
                  },
                  backgroundColor: Colors.lightBlueAccent,
                  child: const Icon(
                    Icons.headphones,
                    size: 24,
                  ),
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