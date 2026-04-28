import 'package:flutter/material.dart';

class NiceDialog {
  static Future<T?> show<T>(BuildContext context,
      {required Widget title,
      Widget? content,
      List<Widget>? actions,
      bool barrierDismissible = true}) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        titleTextStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        contentTextStyle: TextStyle(color: Colors.grey.shade700),
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  static Future<bool?> showConfirm(BuildContext context,
      {required String title,
      required String content,
      String cancelText = 'Cancelar',
      String confirmText = 'Confirmar'}) {
    return show<bool>(
      context,
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
      barrierDismissible: false,
    );
  }
}
