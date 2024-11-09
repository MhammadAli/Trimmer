import 'package:trim/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoTrimScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 4,
            title: Text('Trim'),
            leading: Icon(Icons.cut),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: AppCubit.get(context).sharedVideoPath,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    labelText: 'Video Path',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    AppCubit.get(context).trimVideo();
                  },
                  child: (state is AppTrimmingLoadingState)
                      ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text('Trim'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                    textStyle: TextStyle(fontSize: 30),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      'Choose the duration',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    // DropdownButton<int>(
                    //   value: _selectedSegmentDuration,
                    //   items: _segmentDurations
                    //       .map((duration) => DropdownMenuItem<int>(
                    //     value: duration,
                    //     child: Text('$duration minute(s)'),
                    //   ))
                    //       .toList(),
                    //   onChanged: (value){
                    //     print(value);
                    //     setState(() {
                    //       _selectedSegmentDuration = value!;
                    //     });
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// @override
// void dispose() {
//   _intentDataStreamSubscription.cancel();
//   super.dispose();
// }
