import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:permission_handler/permission_handler.dart'; // Import for permissions
import 'dart:io'; // Import for File and Directory checks

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoTrimScreen(),
    );
  }
}

class VideoTrimScreen extends StatefulWidget {
  @override
  _VideoTrimScreenState createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  String _sharedVideoPath = "No video selected";
  late StreamSubscription _intentDataStreamSubscription;
  final List<SharedMediaFile> _sharedFiles = [];
  Duration totalVideoDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission(); // Request storage permission

    // Listen to media sharing while the app is in memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
          print('77777777777777777');
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
          if (_sharedFiles.isNotEmpty) {
            print('4444444444444444444444444');
            _sharedVideoPath = _sharedFiles.first.path;
            setState(() {

            });
            print(_sharedVideoPath);
            _fetchVideoDuration(_sharedVideoPath);
          }
        }, onError: (err) {
          print("getMediaStream error: $err");
        });

    // Retrieve initial shared media when the app is launched from a sharing intent
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      print('55555555555555555555555555555');
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      if (_sharedFiles.isNotEmpty) {
        print('4444444444444444444444444');
        _sharedVideoPath = _sharedFiles.first.path;
        setState(() {

        });
        print(_sharedVideoPath);
        _fetchVideoDuration(_sharedVideoPath);
      }
      ReceiveSharingIntent.instance.reset(); // Reset sharing intent
    });
  }

  Future<void> _requestStoragePermission() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _fetchVideoDuration(String videoPath) async {
    if (await File(videoPath).exists()) {
      await FFprobeKit.getMediaInformation(videoPath).then((session) {
        final information = session.getMediaInformation();
        if (information != null) {
          final duration = information.getDuration();
          if (duration != null) {
            setState(() {
              totalVideoDuration = Duration(milliseconds: (double.parse(duration) * 1000).toInt());
            });
          }
        }
      });
    } else {
      print("File does not exist at path: $videoPath");
    }
  }

  void _trimVideo() async {
    if (await Permission.storage.isGranted) {
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (totalVideoDuration.inSeconds > 0) {
        final segmentDuration = Duration(minutes: 1);
        int segmentIndex = 0;

        for (int startMs = 0; startMs < totalVideoDuration.inMilliseconds; startMs += segmentDuration.inMilliseconds) {
          final endMs = startMs + segmentDuration.inMilliseconds;
          final actualDurationMs = (endMs > totalVideoDuration.inMilliseconds)
              ? totalVideoDuration.inMilliseconds - startMs
              : segmentDuration.inMilliseconds;

          String outputPath = '${directory.path}/trimmed_video_$segmentIndex.mp4';

          FFmpegKit.executeAsync(
            '-i "$_sharedVideoPath" -ss ${startMs ~/ 1000} -t ${actualDurationMs / 1000} "$outputPath"',
                (session) {
              print('Segment $segmentIndex trimmed and saved to $outputPath');
            },
          );

          segmentIndex++;
        }
      } else {
        print("No valid video duration found to trim.");
      }
    } else {
      print("Storage permission not granted.");
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text('Trim'),
        leading: Icon(Icons.cut),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: _sharedVideoPath,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                labelText: 'Video Path',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: _trimVideo,
              child: Text('Trim'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: Size(150, 50),
                textStyle: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
