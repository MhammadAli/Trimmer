import 'package:trim/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoTrimScreen extends StatelessWidget {
  const VideoTrimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            elevation: 4,
            title: const Text('Trimmer'),
            leading: const Icon(Icons.cut),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: AppCubit.get(context).sharedVideoPath,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on),
                    labelText: 'Video Path',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: (state is AppTrimmingLoadingState)
                      ? null
                      : () {
                          cubit.trimVideo();
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                    textStyle: const TextStyle(fontSize: 30),
                  ),
                  child: (state is AppTrimmingLoadingState)
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Trim'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Text(
                      'Duration of segment',
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
                          (index) => DropdownMenuItem(
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
                              )),
                      onChanged: (value) {
                        cubit.changeDropdownSelection(value!);
                      },
                    ),
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
