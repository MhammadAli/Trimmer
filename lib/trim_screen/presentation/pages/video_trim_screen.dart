import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim/trim_screen/presentation/manager/app_cubit.dart';
import 'package:trim/trim_screen/presentation/widgets/custom_button.dart';
import 'package:trim/trim_screen/presentation/widgets/drop_down_button.dart';
import 'package:trim/trim_screen/presentation/widgets/snackbar_successful_trimming.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoTrimScreen extends StatelessWidget {
  const VideoTrimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppTrimmingSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            showSnackBar(
                color: Colors.green, message: 'Trimming done successfully!'),
          );
        }

        if (state is AppTrimmingErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            showSnackBar(
                color: Colors.red, message: 'Error occurred while trimming.'),
          );
        }

        if (state is AppGettingPermissionErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            showSnackBar(
                color: Colors.red,
                message: 'Storage Permission is necessary for the app'),
          );
        }
      },
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            elevation: 4,
            title: const Text('Trimmer'),
            leading: const Icon(Icons.cut),
          ),
          body: Padding(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              children: [
                TextFormField(
                  controller: cubit.videoName,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Video Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                showButton(
                  text: 'Trim',
                  onPressed: (state is AppTrimmingLoadingState)
                      ? null
                      : () {
                          cubit.trimVideo();
                        },
                  isTrim: true,
                  state: state,
                ),
                SizedBox(
                  height: 20.h,
                ),
                showButton(
                  text: 'Browse',
                  onPressed: () {
                    cubit.pickVideo();
                  },
                  isTrim: false,
                ),
                SizedBox(
                  height: 20.h,
                ),
                dropdownButton(context, cubit),
              ],
            ),
          ),
        );
      },
    );
  }
}
