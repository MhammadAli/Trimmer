import 'package:flutter/material.dart';
import 'package:trim/trim_screen/presentation/widgets/custom_duration_dropdown.dart';

Widget dropdownButton(BuildContext context, cubit) =>
    Row(
      children: [
        const Text(
          'Choose the platform',
          style:
          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: 10,
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
                        const SizedBox(
                          width: 8,
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