import 'dart:io';

import 'package:flutter/material.dart';

import 'package:wave/wave.dart';
import 'package:wave/config.dart';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiService apiService = ApiService();
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? recordingPath;
  String? translated_odio;
  bool isRecording = false, isPlaying = false;
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
                color: Colors.white),
          )),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //si il ya un lien vers un audio
                if (translated_odio != null)
                  ElevatedButton(
                    onPressed: () async {
                       
                        await audioPlayer.setFilePath(translated_odio!);
                        audioPlayer.play();
                        setState(() {
                          isPlaying = true;
                        });
                      
                    },
                    child: Icon(isPlaying ? Icons.stop : Icons.translate),
                  ),
                if (translated_odio == null)
                  const Text(
                    "No translate Found. :(",
                  ),
              ],
            ),
            // si on est entrain d'enregistrer, il fau faire les amplitude
            if (isRecording)
              WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [Colors.lightBlueAccent, Colors.blue],
                  ],
                  durations: [500],
                  heightPercentages: [0.5],
                ),
                size: const Size(300, 100),
                waveAmplitude: 1,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    // si entrain denregistrer, il faut arreter l'enregistrement
                    if (isRecording) {
                      //recuperer le lien de l'audio enreistrer
                      String? filePath = await audioRecorder.stop();
                      if (filePath != null) {
                        setState(() {
                          isRecording = false;
                          //apres avoir stopper lenregistrement on a le lien vers le fichier audio enregistrer
                          recordingPath = filePath;
                        });
                      }
                    }
                    // si on est pa entrain denregistrer, il faut arreter l'enregistrement
                    else {
                      //prendre la permission pour enregistrer
                      if (await audioRecorder.hasPermission()) {
                        final Directory appDocumentsDir =
                            await getApplicationDocumentsDirectory();
                        final String filePath =
                            p.join(appDocumentsDir.path, "recording.wav");

                        await audioRecorder.start(
                          const RecordConfig(encoder: AudioEncoder.wav),
                          path: filePath,
                        );
                        setState(() {
                          isRecording = true;
                          //pendant lenregistrement le lien vers le fichier est nulle
                          recordingPath = null;
                        });
                      }
                    }
                  },
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                  ),
                ),
                FloatingActionButton(
                  onPressed: () async {
                    File audioFile = File(recordingPath!);
                    print("odio $recordingPath");
                    final File translatedAudioFile =
                        await apiService.predict_moore_english_Audio(audioFile);

                    setState(() {
                      translated_odio = translatedAudioFile.path;
                    });
                  },
                  backgroundColor: Colors.lightBlueAccent,
                  child: const Icon(Icons.headphones,
                      size: 24), // Headphones icon button
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
