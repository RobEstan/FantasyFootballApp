import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerModel extends ChangeNotifier{
  bool notificationsOn = true;

  void toggleNotifications(bool value) async{
    notificationsOn = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifsOn', value);
    notifyListeners();
  }

  void setNotificationsOn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    notificationsOn = prefs.getBool('notifsOn') ?? true;
  }
}