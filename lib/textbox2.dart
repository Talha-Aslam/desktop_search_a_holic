// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

Expanded textbox2(
  BuildContext context,
  String text,
  Color topRightColor,
  Color topLeftColor,
  AssetImage logo,
) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topRightColor, topLeftColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: logo, height: 50.0, width: 50.0),
          const SizedBox(height: 10.0),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10.0),
          SimpleCircularProgressBar(
            progressStrokeWidth: 5.0,
            backStrokeWidth: 5.0,
            progressColors: [Colors.white],
            mergeMode: true,
          ),
        ],
      ),
    ),
  );
}
