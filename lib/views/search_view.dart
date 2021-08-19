import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:forat/logic/lobby_logic.dart';
import 'package:forat/models/lobby.dart';
import 'package:forat/models/message.dart';
import 'package:forat/models/topics.dart';
import 'package:forat/utility/show_error_alert.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController _searchController;
  FocusNode _searchFocus;
  bool _isSearching;
  bool _hasSearched;
  List<Lobby> _searchResults;
  List<Lobby> _trendLobbies;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChange);
    _searchFocus = FocusNode();
    _searchFocus.addListener(_onSearchChange);
    _isSearching = false;
    _hasSearched = false;
    _searchResults = [];
    _trendLobbies = [];

    // Getting trend lobbies
    LobbyLogic.getTrendLobbies().then((value) {
      value.sort((a, b) => b.users.length.compareTo(a.users.length));
      setState(() => _trendLobbies = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                elevation: 0,
                title: Text(
                  "Search",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color),
                ),
                flexibleSpace: Align(
                  alignment: Alignment.bottomCenter,
                  child: searchBar(),
                ),
                floating: true,
                collapsedHeight: 130,
                backgroundColor: Colors.white,
              ),
              resultsList(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: Widgets

  Widget searchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context)
                          .unselectedWidgetColor
                          .withAlpha(100),
                      blurRadius: 10)
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                focusNode: _searchFocus,
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search...",
                ),
              ),
            ),
          ),
          SizedBox(width: _isSearching ? 10 : 0),
          _isSearching
              ? MaterialButton(
                  onPressed: onSearch,
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).backgroundColor,
                  child: Icon(
                    FontAwesomeIcons.search,
                    size: 16,
                  ),
                  padding: EdgeInsets.all(12),
                  minWidth: 0,
                  shape: CircleBorder(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget resultsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (!_hasSearched) return resultCell(_trendLobbies[index], index);
          if (_hasSearched && _searchResults.isEmpty) return noResultCell();
          if (_hasSearched) return resultCell(_searchResults[index], index);
          return Container();
        },
        childCount: !_hasSearched
            ? _trendLobbies.length
            : (_hasSearched && _searchResults.isEmpty)
                ? 1
                : (_hasSearched && _searchResults.isNotEmpty)
                    ? _searchResults.length
                    : 0,
      ),
    );
  }

  Widget noResultCell() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Text(
          'No lobbies found for the\ninserted search criteria.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget resultCell(Lobby lobby, int index) {
    return GestureDetector(
      onTap: () => onResultTap(lobby),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                !_hasSearched
                    ? Expanded(
                        child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Color(0xFFFFD700)
                                : index == 1
                                    ? Color(0xFFC0C0C0)
                                    : index == 2
                                        ? Color(0xFFD39C6E)
                                        : Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(child: Text("${index + 1}")),
                        ),
                      ))
                    : SizedBox.shrink(),
                SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lobby.name ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            Chip(
                              elevation: 0,
                              backgroundColor: lobby.topic.color(),
                              label: Text(
                                lobby.topic.name(),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "${lobby.users.length} People",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }

  // MARK: User actions

  void onSearch() async {
    List<Lobby> result = await LobbyLogic.didTapOnSearchButton(
      context,
      nameKeyword: _searchController.text,
    );
    print(result);
    if (result != null)
      setState(() {
        _hasSearched = true;
        _searchResults = result ?? [];
      });
  }

  void onResultTap(Lobby tappedLobby) async {
    Lobby lobby = await LobbyLogic.getLobbyWithId(tappedLobby.key);
    if (lobby != null)
      LobbyLogic.goToLobbyDetailedView(
        context,
        lobby,
      );
    else
      showErrorAlert(context, message: "Unable to find the lobby");
  }

  // MARK: Utility functions

  void _onSearchChange() {
    setState(() {
      _isSearching = _searchFocus.hasFocus &&
          (_searchController.text != "" && _searchController.text != null);
      if (_searchController.text == "") _hasSearched = false;
    });
  }
}
