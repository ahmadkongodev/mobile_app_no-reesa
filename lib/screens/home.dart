import 'dart:io';

import 'package:flutter/material.dart'; 

import 'package:wave/wave.dart';
import 'package:wave/config.dart';
// Import package
 
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? recordingPath; 
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
          color: Colors.white
        ),
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
                if (recordingPath != null)
                  ElevatedButton(
                  
                    onPressed: () async {
                      if (audioPlayer.playing) {
                        audioPlayer.stop();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await audioPlayer.setFilePath(recordingPath!);
                        audioPlayer.play();
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.stop
                          : Icons.translate
                      
                    ),
                  ),
                if (recordingPath == null)
                  const Text(
                    "No translate Found. :(",
                  ),
              ],
            ),
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
                waveAmplitude: 0,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    if (isRecording) {
                      String? filePath = await audioRecorder.stop();
                      if (filePath != null) {
                        setState(() {
                          isRecording = false;
                          recordingPath = filePath;
                        });
                      }
                    } else {
                      if (await audioRecorder.hasPermission()) {
                        final Directory appDocumentsDir =
                            await getApplicationDocumentsDirectory();
                        final String filePath =
                            p.join(appDocumentsDir.path, "recording.wav");
                           
                        await audioRecorder.start(
                          const RecordConfig(),
                          path: filePath,
                        );
                        setState(() {
                          isRecording = true;
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
                  onPressed: () {
                    // Add interaction code here
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
