
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './team.dart';
import './player.dart';

class FavoritesModel extends ChangeNotifier {
  List<Team> favoriteTeams = [];
  List<Player> favoritePlayers = [];
  List<Player> searchResults = [];

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
    bool found = false;
    for (Player p in favoritePlayers) {
      if (p.id == player.id) {
        found = true;
        favoritePlayers.remove(p);
        break;
      }
    }
    if (!found) {
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

  bool isFavPlayer(int id) {
    for (Player player in favoritePlayers) {
      if (player.id == id) {
        return true;
      }
    }
    return false;
  }

  void updateSearchResults(List<Player> results) {
    searchResults = results;
    notifyListeners();
  }

  void clearSearchResults() {
    searchResults = [];
    notifyListeners();
  }


}
