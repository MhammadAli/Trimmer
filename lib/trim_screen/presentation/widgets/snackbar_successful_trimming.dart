import 'package:flutter/material.dart';

SnackBar showSnackBar({
  required String message,
  required color,
}) =>
    SnackBar(
      content: Text(
        message,
      ),
      duration: Duration(seconds: 3),
      backgroundColor: color,
    );
