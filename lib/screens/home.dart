import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:no_reesa/constants.dart';
import 'package:no_reesa/controllers/controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ApiService apiService = ApiService();
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioRecorder audioRecorder2 = AudioRecorder();
  final List<double> wavePoints =
      List.generate(100, (index) => Random().nextDouble() * 2 - 1);

  //Functions for moore to English
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
    String recordingPath = Controller.instance.recordingPath.value;
    File audioFile = File(recordingPath);
    final File translatedAudioFile =
        await apiService.predictMooreToEnglish(audioFile);
    Controller.instance.setTranslatedAudioPath(translatedAudioFile.path);
  }

  // Functions for English to moore

  Future<void> stopRecordingAndSave2() async {
    // récupérer le lien de l'audio enregistré
    String? filePath = await audioRecorder2.stop();
    if (filePath != null) {
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

    if (recordingPath.isEmpty) {
      Controller.instance.showErrorDialog("erreur");
      return;
    }

    File audioFile = File(recordingPath);
    if (!audioFile.existsSync()) {
      Controller.instance.showErrorDialog("erreur");
      return;
    }

    try {
      final File translatedAudioFile =
          await apiService.predictEnglishToMoore(audioFile);
      Controller.instance.setTranslatedAudioPath2(translatedAudioFile.path);
    } catch (e) {
      Controller.instance.showErrorDialog("erreur");
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
                Obx(() => Controller.instance.isRecording.value ||
                        Controller.instance.isRecording2.value ||
                        Controller.instance.isPlaying.value ||
                        Controller.instance.isPlaying2.value
                    ? Container()
                    : Image.asset(
                        "assets/voice.jpg",
                        width: 300,
                        height: 300,
                      )),
              ],
            ),
            Obx(() => Controller.instance.isRecording.value ||
                    Controller.instance.isRecording2.value ||
                    Controller.instance.isPlaying.value ||
                    Controller.instance.isPlaying2.value
                ? Lottie.asset(
                    "assets/Animation.json",
                    repeat: true,
                  )
                : Container()),
            Obx(
              () => Controller.instance.isRecording.value ||
                      Controller.instance.isRecording2.value ||
                      Controller.instance.isPlaying.value ||
                      Controller.instance.isPlaying2.value
                  ? SizedBox(height: MediaQuery.of(context).size.height * 0)
                  : SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ),
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
                    decoration: BoxDecoration(
                        color: niceColor,
                        borderRadius: BorderRadius.circular(50)),
                    child: Obx(
                      () => Container(
                        height: 100,
                        width: 100,
                        child: Controller.instance.isRecording.value
                            ? const Icon(Icons.stop)
                            :   CircleAvatar(
                              backgroundColor: niceColor,
                              radius: 68,
                              child: const CircleAvatar(
                                  radius: 48, // Image radius
                                  backgroundImage: AssetImage(
                                      'assets/drapeau-burkina.jpg'),
                                ),
                            ),
                      ),
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
                    decoration: BoxDecoration(
                        color: niceColor,
                        borderRadius: BorderRadius.circular(50)),
                    child: Obx(() => Container(
                      height: 100,
                      width: 100,                            
                      child:   
                            Controller.instance.isRecording2.value
                                ? const Icon(Icons.stop)
                                :    CircleAvatar(
                              backgroundColor: niceColor,
                              radius: 68,
                              child: const CircleAvatar(
                                  radius: 48, // Image radius
                                  backgroundImage: AssetImage(
                                      'assets/drapeau-anglais.jpg'),
                                ),
                            ),
                          )),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
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
