import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../enums/screens.dart';

ScreenSize getScreenSize(BuildContext context) {
  final screenSize = MediaQuery.sizeOf(context).width;

  if (screenSize < smallScreenWidth) {
    return ScreenSize.small;
  } else if (screenSize >= smallScreenWidth && screenSize < mediumScreenWidth) {
    return ScreenSize.medium;
  }
  return ScreenSize.large;
}

void copyToClipboard(BuildContext context, String title, String content) {
  Clipboard.setData(ClipboardData(text: content));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$title copied to clipboard'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

String formatDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat.yMMMd().format(date);
}

Future<bool> showDeleteConfirmation(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      ) ??
      false;
}
