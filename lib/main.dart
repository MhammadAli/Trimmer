import 'package:flutter/material.dart';
import 'package:trim/cubit/app_cubit.dart'; // Import for File and Directory checks
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim/home_layout/video_trim_screen.dart';
import 'bloc_observer.dart';
void main() {
   Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => AppCubit()..init(),
  child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoTrimScreen(),
    ),
);
  }
}