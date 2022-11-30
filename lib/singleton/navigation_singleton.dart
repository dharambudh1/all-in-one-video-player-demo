import 'package:flutter/material.dart';

class Singleton {
  static final Singleton _singleton = Singleton._internal();

  factory Singleton() {
    return _singleton;
  }

  GlobalKey<NavigatorState> navigatorStateKey = GlobalKey<NavigatorState>();

  Singleton._internal();
}
