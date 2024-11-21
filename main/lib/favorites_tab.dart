import 'package:flutter/material.dart';
import 'package:main/display_team.dart';
import 'package:main/favorites_model.dart';
import 'package:main/player.dart';
import 'package:provider/provider.dart';
import 'package:main/display_player.dart';
import './team.dart';

class FavoritesTab extends StatefulWidget {
  final List<Team> teams;
  final int favoriteTeamId;
  const FavoritesTab(
      {super.key, required this.teams, required this.favoriteTeamId});

  @override
  State<FavoritesTab> createState() => _FavoritesTab();
}

class _FavoritesTab extends State<FavoritesTab> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(
        length: (Provider.of<FavoritesModel>(context).favoriteTeams.length +
            Provider.of<FavoritesModel>(context).favoritePlayers.length),
        vsync: this);
    List<Widget> tabTitles = [];
    List<Widget> tabContents = [];

    for (Team team in Provider.of<FavoritesModel>(context).favoriteTeams) {
      tabTitles.add(Tab(
        child: Image(image: NetworkImage(team.logo)),
      ));
      tabContents.add(DisplayTeam(
        team: team,
        teams: widget.teams,
        showAppBar: false,
      ));
    }

    for (Player player
        in Provider.of<FavoritesModel>(context).favoritePlayers) {
      tabTitles.add(Tab(
        text: player.name,
      ));
      tabContents.add(DisplayPlayer(player: player, showAppBar: false));
    }

    return tabController.length == 0
        ? const Center(child: Text('No Favorites'))
        : Column(
            children: [
              TabBar.secondary(
                controller: tabController,
                tabs: tabTitles,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
              Expanded(
                child: TabBarView(
                    controller: tabController, children: tabContents),
              ),
            ],
          );
  }
}
