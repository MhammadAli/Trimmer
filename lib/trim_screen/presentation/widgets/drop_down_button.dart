import 'package:flutter/material.dart';
import 'package:trim/trim_screen/presentation/widgets/custom_duration_dropdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Row dropdownButton(BuildContext context, cubit) =>
    Row(
      children: [
         Text(
          'Choose the platform',
          style:
          TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
         SizedBox(
          width: 10.w,
        ),
        DropdownButton<int>(
          value: cubit.selectedSegmentIndex,
          items: List.generate(
              cubit.segmentDurations.length,
                  (index) =>
                  DropdownMenuItem(
                    value: index,
                    child: Row(
                      children: [
                        Icon(cubit.segmentDurations[index]['icon']),
                         SizedBox(
                          width: 8.w,
                        ),
                        Text(cubit.segmentDurations[index]['name'])
                      ],
                    ),
                  ))
            ..add(
              const DropdownMenuItem(
                value: -1,
                child: Text(
                  'Custom',
                ),
              ),
            ),
          onChanged: (value) {
            if (value == -1) {
              showCustomDurationDialog(context,cubit);
              cubit.changeDropdownSelection(value!);
            } else {
              cubit.changeDropdownSelection(value!);
            }
          },
        ),
      ],
    );