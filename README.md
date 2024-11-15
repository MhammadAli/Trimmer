# Video Trimmer App

The Video Trimmer App is a feature-rich Flutter application that lets you efficiently trim, split, and manage video files. With support for custom segment durations, share intents, and platform-specific options, this app offers an intuitive and seamless video editing experience.

---

## Features

- **Browse and Select Videos**: Easily browse your device to select a video file for trimming.
- **Video Trimming**: Trim videos with custom start and end timestamps.
- **Automatic Splitting**: Automatically split videos into smaller segments of specified durations.
- **Platform-Specific Segments**: Choose predefined segment durations for platforms like WhatsApp and Messenger.
- **Custom Duration Input**: Input custom durations for video trimming.
- **Share Videos**: Share videos directly into the app.
- **Intuitive UI**: User-friendly design for smooth navigation and interaction.
- **Storage Permission Handling**: Automatically handles storage permissions for a seamless experience.

---

## Packages Used

- **[flutter_bloc](https://pub.dev/packages/flutter_bloc)**: For state management.
- **[file_picker](https://pub.dev/packages/file_picker)**: To browse and pick video files.
- **[ffmpeg_kit_flutter](https://pub.dev/packages/ffmpeg_kit_flutter)**: For video processing and trimming.
- **[permission_handler](https://pub.dev/packages/permission_handler)**: To request and handle storage permissions.
- **[ffprobe_kit_flutter](https://pub.dev/packages/ffprobe_kit_flutter)**: To fetch video metadata, such as duration and filename.