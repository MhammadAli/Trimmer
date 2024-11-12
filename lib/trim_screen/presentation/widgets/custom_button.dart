import 'package:flutter/material.dart';
import 'package:trim/trim_screen/presentation/manager/app_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

OutlinedButton showButton(
        {required String text, required onPressed, isTrim,state}) =>
    OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize:  Size(150.w, 50.h),
        textStyle:  TextStyle(fontSize: 30.sp),
      ),
      child: (state is AppTrimmingLoadingState && isTrim)
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(text),
    );
