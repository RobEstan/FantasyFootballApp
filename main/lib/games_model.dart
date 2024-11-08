import 'package:flutter/material.dart';
import './game.dart';

class GamesModel extends ChangeNotifier {
  late Game currGame;

  void editCurrGame(Game game) {
    currGame = game;
    notifyListeners();
  }
}