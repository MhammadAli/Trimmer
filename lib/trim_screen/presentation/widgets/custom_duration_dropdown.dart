import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Method to show a dialog for custom duration input
Future showCustomDurationDialog(BuildContext context,cubit) {
  int customValue = 1; // Default custom duration
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Custom Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input for custom duration
              TextFormField(
                initialValue: customValue.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration'),
                onChanged: (value) {
                  customValue = int.tryParse(value) ?? 1;
                },
              ),
              SizedBox(height: 10.h),
              // Dropdown for unit selection (minutes or seconds)
              DropdownButton<int>(
                value: cubit.selectedCustomSegmentIndex,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Minutes'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Seconds'),
                  ),
                ],
                onChanged: (value) {
                  setState((){
                    cubit.changeDropdownCustomSelection(value!);
                    print(cubit.selectedCustomSegmentIndex);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save the custom duration and unit in the cubit
                cubit.setCustomDuration(customValue);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );
}