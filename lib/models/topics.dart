import 'package:flutter/material.dart';

enum Topics {
  football,
  cooking,
  sport,
  job,
  technology,
  cinema,
  art,
  medicine,
  beer,
  tv
}

extension TopicsHelper on Topics {
  int toInt() {
    if (this == null) return null;
    return this.index;
  }

  static Topics fromInt(int index) {
    if (index == null) return null;
    return Topics.values[index];
  }

  Color color() {
    if (this == null) return Colors.black;
    if (this.toInt() > 9 || this.toInt() < 0) return Colors.black;

    final List<Color> colors = [
      Colors.red[700],
      Colors.blue[300],
      Colors.yellow[300],
      Colors.green[300],
      Colors.purple[300],
      Colors.brown[300],
      Colors.amber[800],
      Colors.grey[300],
      Colors.teal[700],
      Colors.deepOrange[300],
    ];

    return colors[this.toInt()].withAlpha(100);
  }

  String name() {
    if (this == null) return "";
    return this.toString().split('.').last;
  }

  static Topics fromString(String value) {
    for (var topic in Topics.values) {
      if (topic.name() == value) return topic;
    }
    return null;
  }
}
