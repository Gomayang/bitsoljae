import 'package:flutter/material.dart';

// 1080*2340
const int originWidth = 1080;
const int originHeight = 2340;

double getScaleWidth(BuildContext context) {
  return MediaQuery.of(context).size.width / originWidth;
}

// double getScaleHeight(BuildContext context) {
//   return MediaQuery.of(context).size.height / originHeight;
// }

Widget xMargin(double width, BuildContext context) {
  return SizedBox(
    width: width * getScaleWidth(context),
  );
}

Widget yMargin(double height, BuildContext context) {
  return SizedBox(
    height: height * getScaleWidth(context),
  );
}

Widget infoDialog({
  required String title,
  required String body,
  required BuildContext context,
}) {
  return AlertDialog(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 50 * getScaleWidth(context),
        fontWeight: FontWeight.bold,
      ),
    ),
    content: Text(
      body,
      style: TextStyle(
        fontSize: 50 * getScaleWidth(context),
      ),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('확인'),
      ),
    ],
  );
}

Widget colorContainer(Color color) {
  return Container(
    color: color,
    child: const SizedBox.expand(),
  );
}

Future<bool> waitForMounted(BuildContext context) async {
  while (!context.mounted) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  return true;
}
