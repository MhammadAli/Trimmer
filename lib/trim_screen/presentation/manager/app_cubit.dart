import 'dart:async';
import 'dart:io'; // Import for File and Directory checks
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:path/path.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  final sharedVideoPath = TextEditingController();
  late StreamSubscription _intentDataStreamSubscription;
  final List<SharedMediaFile> _sharedFiles = [];
  Duration totalVideoDuration = Duration.zero;
  TextEditingController videoName = TextEditingController();

  // Dropdown data structure with platform icons and durations
  final List<Map<String, dynamic>> segmentDurations = [
    {
      'name': 'WhatsApp',
      'icon': FontAwesomeIcons.whatsapp,
      'duration': const Duration(minutes: 1)
    },
    {
      'name': 'Messenger',
      'icon': FontAwesomeIcons.facebookMessenger,
      'duration': const Duration(seconds: 20)
    },
    {
      'name': 'YouTube',
      'icon': FontAwesomeIcons.youtube,
      'duration': const Duration(minutes: 3)
    },
    {
      'name': 'TikTok',
      'icon': FontAwesomeIcons.tiktok,
      'duration': const Duration(minutes: 10)
    },
    {
      'name': 'Telegram',
      'icon': FontAwesomeIcons.telegram,
      'duration': const Duration(minutes: 1)
    }, // Default custom duration
  ];

  int selectedSegmentIndex = 0; // Track selected index
  int selectedCustomSegmentIndex = 0;
  bool isCustom = false;
  Duration customDuration = Duration.zero;

  Duration get selectedSegmentDuration => (isCustom)
      ? customDuration
      : segmentDurations[selectedSegmentIndex]['duration'];

  void trimVideo() async {
    await requestStoragePermission(); // Request storage permission
    if (await Permission.storage.isGranted) {
      final directory = Directory('/storage/emulated/0/Trimmer');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      emit(AppTrimmingLoadingState());

      if (totalVideoDuration.inSeconds > 0) {
        final segmentDuration = selectedSegmentDuration;
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
              '${directory.path}/${videoName}_$segmentIndex.mp4';

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
        emit(AppFetchDurationErrorState());
        print("No valid video duration found to trim.");
      }
    } else {
      emit(AppGettingPermissionErrorState());
      print("Storage permission not granted.");
    }
  }

  void init() {
    emit(AppInitialState());
    // Listen to media sharing while the app is in memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      if (_sharedFiles.isNotEmpty) {
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
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      if (_sharedFiles.isNotEmpty) {
        sharedVideoPath.text = _sharedFiles.first.path;
        fetchVideoDuration(sharedVideoPath.text);
      }
      ReceiveSharingIntent.instance.reset(); // Reset sharing intent
    });
  }

  Future<void> requestStoragePermission() async {
    emit(AppGettingPermissionState());
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
          videoName.text = basename(information.getFilename()!);
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

  void changeDropdownSelection(int index) {
    selectedSegmentIndex = index;
    isCustom = false;
    emit(AppChangeDropdownState());
  }

  void changeDropdownCustomSelection(int index) {
    selectedCustomSegmentIndex = index;
    isCustom = true;
    emit(AppChangeCustomDropdownState());
  }

  void setCustomDuration(int duration) {
    isCustom = true;
    customDuration = (selectedCustomSegmentIndex == 0)
        ? Duration(minutes: duration)
        : Duration(seconds: duration);
  }

  void pickVideo() async {
    emit(AppBrowseLoadingState());
    final path = await FlutterDocumentPicker.openDocument(
      params: FlutterDocumentPickerParams(
        allowedMimeTypes: ['video/*'],
      ),
    );

    if (path != null) {
      sharedVideoPath.text = path;
      fetchVideoDuration(path);
      emit(AppBrowseSuccessState());
    } else {
      emit(AppBrowseErrorState());
      print("No video selected");
    }
  }

  @override
  Future<void> close() {
    // to clean resources and it's equal to dispose function in stateful widget.
    _intentDataStreamSubscription.cancel();
    return super.close();
  }
}
