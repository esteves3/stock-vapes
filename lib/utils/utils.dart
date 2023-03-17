import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_vapes/utils/constants.dart';

class Util {
  static double getSidePadding(BuildContext context, {double val = 0.04}) {
    return MediaQuery.of(context).size.width * val;
  }

  static double getResponsiveValue(
      ResponsiveFlags flag, BuildContext context, double value) {
    switch (flag) {
      case ResponsiveFlags.height:
        {
          return (MediaQuery.of(context).size.height * value) /
              Constants.prototypeHeight;
        }
      case ResponsiveFlags.width:
        {
          return (MediaQuery.of(context).size.width * value) /
              Constants.prototypeWidth;
        }
    }
  }

  static FontWeight getFontWeightByFlag(FontFlags flag) {
    switch (flag) {
      case FontFlags.medium:
        return FontWeight.w500;
      case FontFlags.regular:
        return FontWeight.w400;
      case FontFlags.light:
        return FontWeight.w300;
      case FontFlags.extraLight:
        return FontWeight.w200;
    }
  }

  static List<BoxShadow> getShadowsForContainer() {
    return [
      BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 4,
          offset: const Offset(0, 1)),
      BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 4,
          offset: const Offset(1, 0))
    ];
  }

  static void getBottomSheetMin(BuildContext context, List<Widget> lst,
      {Color backgroundColor = Colors.white}) {
    showModalBottomSheet(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Column(
                children: lst,
              ),
            ],
          );
        });
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
        break;
    }
  }
}

class LimitRangeTextInputFormatter extends TextInputFormatter {
  LimitRangeTextInputFormatter(this.min, this.max) : assert(min < max);

  final int min;
  final int max;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (int.tryParse(newValue.text) == null) {
      return oldValue;
    }

    var nValue = int.parse(newValue.text);
    if (nValue > max) {
      var oValue = int.parse(oldValue.text);
      return TextEditingValue(
          text: oValue.toString(),
          selection: TextSelection.collapsed(offset: oValue.toString().length));
    }
    return newValue;
  }
}
