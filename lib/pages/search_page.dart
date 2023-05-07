import 'package:flutter/material.dart';
import '../google_api.dart';
import '../constants.dart' as constants;

class AddressSearch extends SearchDelegate<Suggestion> {
  final String hint;
  late GoogleApiProvider apiClient;
  BuildContext context;

  AddressSearch(sessionToken, this.hint, this.context) {
    apiClient = GoogleApiProvider(sessionToken);
  }

  @override
  String get searchFieldLabel => hint;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(color: constants.searchBarBG, elevation: 0),
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white, fontSize: 18)),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: constants.accentColor,
      ),
      hintColor: constants.searchHint,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear, color: Colors.white),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, Suggestion('', '', ''));
      },
    );
  }

  Widget _callAPIandBuildList(BuildContext context) {
    return FutureBuilder(
      future: query == "" ? null : apiClient.fetchSuggestions(query),
      builder: (context, AsyncSnapshot snapshot) => query == ''
          ? SizedBox.expand(child: Container(color: constants.mainBG))
          : snapshot.hasData
              ? Container(
                  color: constants.mainBG,
                  child: ListView.builder(
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                      minLeadingWidth: 20,
                      title: Text(
                        (snapshot.data[index] as Suggestion).mainText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text((snapshot.data[index] as Suggestion).secondaryText,
                          style: const TextStyle(color: constants.searchHint)),
                      onTap: () {
                        close(context, snapshot.data[index] as Suggestion);
                      },
                    ),
                    itemCount: snapshot.data.length,
                  ),
                )
              : SizedBox.expand(child: Container(color: constants.mainBG)),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // return _callAPIandBuildList(context);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _callAPIandBuildList(context);
  }
}
