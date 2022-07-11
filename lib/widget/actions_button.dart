import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final String text;

  ActionButton({required this.onPressed, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      padding: const EdgeInsets.all(10.0),
    );
  }
}
