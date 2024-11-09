import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // Import for File and Directory checks
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  var sharedVideoPath = TextEditingController();
  late StreamSubscription _intentDataStreamSubscription;
  final List<SharedMediaFile> _sharedFiles = [];
  Duration totalVideoDuration = Duration.zero;

  // Segment duration dropdown
  int _selectedSegmentDuration = 1; // default duration in minutes
  final List<int> _segmentDurations = [
    1,
    2,
    5,
    10,
  ]; // available options in minutes

  void trimVideo() async {
    requestStoragePermission(); // Request storage permission
    if (await Permission.storage.isGranted) {
      final directory = Directory('/storage/emulated/0/Trimmer');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      emit(AppTrimmingLoadingState());

      if (totalVideoDuration.inSeconds > 0) {
        final segmentDuration = Duration(minutes: _selectedSegmentDuration);
        int segmentIndex = 0;
        bool isSuccess = true; // Track if all segments are trimmed successfully

        List<Future<void>> trimTasks = [];

        for (int startMs = 0;
        startMs < totalVideoDuration.inMilliseconds;
        startMs += segmentDuration.inMilliseconds) {
          final endMs = startMs + segmentDuration.inMilliseconds;
          final actualDurationMs = (endMs > totalVideoDuration.inMilliseconds)
              ? totalVideoDuration.inMilliseconds - startMs
              : segmentDuration.inMilliseconds;

          String outputPath =
              '${directory.path}/trimmed_video_$segmentIndex.mp4';

          // Create a completer to handle the asynchronous callback
          Completer<void> completer = Completer<void>();

          // Use FFmpegKit to execute the command
          FFmpegKit.executeAsync(
            '-i "${sharedVideoPath.text}" -ss ${startMs ~/ 1000} -t ${actualDurationMs / 1000} "$outputPath"',
                (session) async {
              final returnCode = await session.getReturnCode();
              if (returnCode!.isValueSuccess()) {
                print('Segment $segmentIndex trimmed and saved to $outputPath');
              } else {
                print("Error trimming segment $segmentIndex.");
                isSuccess = false; // Mark as failed
              }
              completer.complete(); // Complete the task
            },
          );

          trimTasks.add(completer.future);
          segmentIndex++;
        }

        // Wait for all trim tasks to complete
        await Future.wait(trimTasks);

        // Emit success state only if all segments were trimmed successfully
        if (isSuccess) {
          emit(AppTrimmingSuccessState());
        } else {
          emit(AppTrimmingErrorState());
        }
      } else {
        emit(AppTrimmingErrorState());
        print("No valid video duration found to trim.");
      }
    } else {
      emit(AppTrimmingErrorState());
      print("Storage permission not granted.");
    }
  }


  void init() {
    emit(AppInitialState());
    // Listen to media sharing while the app is in memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      print('77777777777777777');
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      if (_sharedFiles.isNotEmpty) {
        print('4444444444444444444444444');
        sharedVideoPath.text = _sharedFiles.first.path;
        print(sharedVideoPath.text);
        fetchVideoDuration(sharedVideoPath.text);
      }
    }, onError: (err) {
      emit(AppErrorState());
      print("getMediaStream error: $err");
    });

    // Retrieve initial shared media when the app is launched from a sharing intent
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      print('55555555555555555555555555555');
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      if (_sharedFiles.isNotEmpty) {
        print('4444444444444444444444444');
        sharedVideoPath.text = _sharedFiles.first.path;
        print(sharedVideoPath.text);
        fetchVideoDuration(sharedVideoPath.text);
      }
      ReceiveSharingIntent.instance.reset(); // Reset sharing intent
    });
  }

  Future<void> requestStoragePermission() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> fetchVideoDuration(String videoPath) async {
    emit(AppFetchDurationState());
    if (await File(videoPath).exists()) {
      await FFprobeKit.getMediaInformation(videoPath).then((session) {
        final information = session.getMediaInformation();
        if (information != null) {
          final duration = information.getDuration();
          if (duration != null) {
            totalVideoDuration =
                Duration(milliseconds: (double.parse(duration) * 1000).toInt());
          }
        }
      });
    } else {
      emit(AppErrorState());
      print("File does not exist at path: $videoPath");
    }
  }

  @override
  Future<void> close() {  // to clean resources and it's equal to dispose function in stateful widget.
    _intentDataStreamSubscription.cancel();
    return super.close();
  }
}
