import 'package:flutter/material.dart';
import 'package:trim/cubit/app_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim/home_layout/video_trim_screen.dart';
import 'bloc_observer.dart';
void main() {
   Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


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