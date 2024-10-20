import 'package:flutter/material.dart';

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

void showCustomDialog(BuildContext context, dynamic title, dynamic message, {bool? closeButton}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: title is String ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, style: const TextStyle(fontSize: 28, color: Colors.blueGrey))),
            ),
            if(closeButton != null && closeButton)
              ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text("X"))
          ],
        ): title,
        content: message is String ? Text(message, style: const TextStyle(fontSize: 24)) : message,
      );
    },
  );
}


void showConfirmDialog(BuildContext context, String title, String message, Function() onConfirm,{String? confirmText, String? cancelText}){
  showDialog(
    context: context,
    builder: (context){
    return AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 28,fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10,bottom: 20),
              child: Text(message, style: const TextStyle(fontSize: 26)),
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
                onConfirm();
              }, child: Text(confirmText ?? '確定', style: const TextStyle(fontSize: 24)),),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text(cancelText ?? '取消', style: const TextStyle(fontSize: 24))),
            ),
          ],
        ),
    );
    }
  );
}