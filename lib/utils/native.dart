import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Native {
  static void goToPageReplacement(BuildContext context, Widget classTo) {
    Navigator.pushReplacement(
      context,
      routeAnimation(classTo),
    );
  }

  static void goToPage(BuildContext context, Widget classTo) {
    Navigator.push(
      context,
      routeAnimation(classTo),
    );
  }

  static Route routeAnimation(Widget classTo) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageRoute(builder: (BuildContext context) => classTo);
    } else {
      return MaterialPageRoute(builder: (BuildContext context) => classTo);
    }
  }

  static Future<bool> showNativeDialog(
      BuildContext context,
      Widget title,
      Widget content,
      String? cancelActionText,
      String defaultActionText) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: title,
          content: content,
          actions: [
            if (cancelActionText != null)
              TextButton(
                child: Text(cancelActionText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            TextButton(
              child: Text(defaultActionText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }

    return await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          if (cancelActionText != null)
            CupertinoDialogAction(
              child: Text(cancelActionText),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          CupertinoDialogAction(
            child: Text(defaultActionText),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
