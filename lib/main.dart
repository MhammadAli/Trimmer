import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim/trim_screen/presentation/manager/app_cubit.dart';
import 'package:trim/trim_screen/presentation/manager/bloc_observer.dart';
import 'package:trim/trim_screen/presentation/pages/video_trim_screen.dart';
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