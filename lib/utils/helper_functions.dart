import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDateTime(num dt, String pattern) {
  return DateFormat(pattern)
      .format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));
}

showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

showMsgWithAction({
  required BuildContext context,
  required String msg,
  required String actionButtonTitle,
  required VoidCallback onPressedSettings
}) {
  ScaffoldMessenger
      .of(context)
      .showSnackBar(
      SnackBar(
        duration: const Duration(days: 365),
        content: Text(msg),
        action: SnackBarAction(
          label: actionButtonTitle,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onPressedSettings();
          },
        ),
      ));
}

Future<bool> isConnectedToInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}
