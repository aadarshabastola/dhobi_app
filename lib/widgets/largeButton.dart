import 'package:flutter/material.dart';

class LargeButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;

  LargeButton({this.title, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        height: 50,
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
