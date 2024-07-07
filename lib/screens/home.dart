import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:no_reesa/constants.dart';
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
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
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
    final File translatedAudioFile =
        await apiService.predictMooreToEnglish(audioFile);
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
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, "audio_anglais.wav");

      await audioRecorder2.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath,
      );

      Controller.instance.setRecordingTrue2();
    }
  }

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
      final File translatedAudioFile =
          await apiService.predictEnglishToMoore(audioFile);
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
        backgroundColor: niceColor,
        centerTitle: true,
        title: const Text(
          'No-Reesa',
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
           children: <Widget>[
            Column(
               
              children: [
                Container(
                  child: Stack(children: [
                    Opacity(
                      opacity: 0.5,
                      child: ClipPath(
                        clipper: WaveClipper(),
                        child: Container(
                          color: niceColor,
                          height: 200,
                        ),
                      ),
                    ),
                     ClipPath(
                        clipper: WaveClipper(),
                        child: Container(
                          color: niceColor,
                          height: 180,
                        ),
                      ),
                  ]),
                ),
                Obx(() => Controller.instance.recordingPath.value.isEmpty
                    ? const Text("No translate Found. :(")
                    : Container()),
              ],
            ),
            Obx(() => Controller.instance.isRecording.value ||
                    Controller.instance.isRecording2.value
                ? const DisplayWaves()
                : Container()),
              SizedBox(height: MediaQuery.of(context).size.height* 0.3),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () async {
                    if (Controller.instance.isRecording.value) {
                      await stopRecordingAndSave();
                    } else {
                      await record();
                    }
                  },
                  child: Ink(
                    decoration: BoxDecoration(color: niceColor,
                        borderRadius: BorderRadius.circular(50)
                       ),
                    child: Container(
                      height: 100,
                      width: 100,
                       
                      child: Obx(() => Icon(
                          Controller.instance.isRecording.value
                              ? Icons.stop
                              : Icons.mic,
                          color: Colors.white,
                          size: 60,
                        )),
                    ),
                  ),
                ),
                 InkWell(
                    onTap: () async {
                   if (Controller.instance.isRecording2.value) {
                      await stopRecordingAndSave2();
                    } else {
                      await record2();
                    }
                  },
                  child: Ink(
                     decoration: BoxDecoration(color: niceColor,
                        borderRadius: BorderRadius.circular(50)
                       ),
                    child: Container(
                      height: 100,
                      width: 100,    
                      child: Obx(() => Icon(
                          Controller.instance.isRecording2.value
                              ? Icons.stop
                              : Icons.headphones,
                          color: Colors.white,
                          size: 60,
                        )),
                    ),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    var path = new Path();
    path.lineTo(0, size.height); //start path with this if you a
    var firstStart = Offset(size.width / 5, size.height);
//fist point of quadratic bezier curve
    var firstEnd = Offset(size.width / 2.25, size.height - 50.0);
//second point of quadratic bezier curve
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart =
        Offset(size.width - (size.width / 3.24), size.height - 105);
//third point of quadratic bezier curve
    var secondEnd = Offset(size.width, size.height - 10);
//fourth point of quadratic bezier curve
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0); //end with this path if you are making
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
