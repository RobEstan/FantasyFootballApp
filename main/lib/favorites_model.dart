import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './team.dart';
import './player.dart';

class FavoritesModel extends ChangeNotifier {
  List<Team> favoriteTeams = [];
  List<Player> favoritePlayers = [];

  void saveToSharedPrefs() async {
    List<String> favTeamNames = [];
    List<String> favPlayerNames = [];
    List<String> favTeamIDs = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (favoriteTeams.isNotEmpty) {
      favTeamNames = favoriteTeams.map((t) {
        return t.name;
      }).toList();
      favTeamIDs = favoriteTeams.map((t) {
        return t.id.toString();
      }).toList();
    }
    if (favoritePlayers.isNotEmpty) {
      favPlayerNames = favoritePlayers.map((p) {
        return p.name;
      }).toList();
    }
    prefs.setStringList('favoriteTeams', favTeamNames);
    prefs.setStringList('favoritePlayers', favPlayerNames);
    prefs.setStringList('favoriteTeamsID', favTeamIDs);
  }

  void editFavTeams(Team team) {
    if (isFavTeam(team)) {
      favoriteTeams.remove(team);
    } else {
      favoriteTeams.add(team);
    }
    saveToSharedPrefs();
    notifyListeners();
  }

  void addFavPlayer(Player player) {
    if (favoritePlayers.contains(player)) {
      favoritePlayers.remove(player);
    } else {
      favoritePlayers.add(player);
    }
    saveToSharedPrefs();
    notifyListeners();
  }

  bool isFavTeam(Team team) {
    if (favoriteTeams.contains(team)) {
      return true;
    }

    return false;
  }

  bool isFavPlayer(Player player) {
      if (favoritePlayers.contains(player)) {
        return true;
      }

      return false;
    }
}