import 'package:flutter/material.dart';
import './team.dart';
import './player.dart';

class FavoritesModel extends ChangeNotifier {
  List<Team> favoriteTeams = [];
  List<Player> favoritePlayers = [];

  void editFavTeams(Team team) {
    if (isFavTeam(team)) {
      favoriteTeams.remove(team);
    } else {
      favoriteTeams.add(team);
    }
    notifyListeners();
  }

  void addFavPlayer(Player player) {
    if (favoritePlayers.contains(player)) {
      favoritePlayers.remove(player);
    } else {
      favoritePlayers.add(player);
    }
    notifyListeners();
  }

  bool isFavTeam(Team team) {
    if (favoriteTeams.contains(team)) {
      return true;
    }

    return false;
  }
}