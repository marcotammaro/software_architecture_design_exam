import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showErrorAlert(
  BuildContext context, {
  String message,
  VoidCallback onCancel,
}) {
  Widget cancelButton = TextButton(
    child: Text(
      "Dismiss",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
    onPressed: () {
      if (onCancel != null) onCancel();
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );

  Widget title = Text(
    'Error',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  Widget content = Text(
    message,
    style: TextStyle(fontSize: 14),
  );

  // set up the AlertDialog
  var alert = Platform.isAndroid
      ? AlertDialog(
          title: title,
          content: content,
          actions: [cancelButton],
        )
      : CupertinoAlertDialog(
          title: title,
          content: content,
          actions: [cancelButton],
        );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
