// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks, avoid_unnecessary_containers

import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final String labelText;
  final String hintText;

  const TextBox({
    super.key,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
