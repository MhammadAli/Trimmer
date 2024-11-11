import 'package:flutter/material.dart';
import 'package:trim/trim_screen/presentation/manager/app_cubit.dart';

OutlinedButton showButton(
        {required String text, required onPressed, isTrim,state}) =>
    OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
        textStyle: const TextStyle(fontSize: 30),
      ),
      child: (state is AppTrimmingLoadingState && isTrim)
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(text),
    );
