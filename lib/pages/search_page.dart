import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/google_api.dart';
import '../helpers/constants.dart' as constants;
import '../language_constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.sessionToken, required this.hint});

  final String sessionToken;
  final String hint;

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Suggestion> _suggestions = [];
  late GoogleApiProvider _apiProvider;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiProvider = GoogleApiProvider(widget.sessionToken);
  }

  Future<void> _testPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return;
  }

  Future<Position> _getPosition() async {
    return _testPermission().then((_) async {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
    });
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: constants.mainBG,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 70,
          title: TextField(
            controller: _controller,
            onChanged: (query) async {
              List<Suggestion> fetchedSuggestions = [];
              if (query != '') {
                fetchedSuggestions = await _apiProvider.fetchSuggestions(query);
              }
              setState(() {
                _suggestions = fetchedSuggestions;
              });
            },
            style: const TextStyle(color: constants.text, fontSize: 20),
            cursorColor: constants.accentColor,
            decoration: InputDecoration(
              hintText: widget.hint,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(width: 1, color: constants.hint)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(width: 1, color: constants.hint)),
              hintStyle: const TextStyle(color: constants.hint, fontSize: 20),
              prefixIcon: IconButton(
                onPressed: () => Navigator.pop(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(Icons.arrow_back),
                color: constants.text,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _suggestions = [];
                  });
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(Icons.clear),
                color: constants.text,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: constants.searchBarBG,
          shape: const Border(bottom: BorderSide(color: constants.searchBarBG, width: 0)),
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: _getPosition(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, [
                        '${snapshot.data!.latitude},${snapshot.data!.longitude}',
                        translation(context).yourLocation
                      ]);
                    },
                    // tileColor: constants.searchBarBG,
                    leading: const Icon(
                      Icons.my_location_outlined,
                      color: constants.accentColor,
                    ),
                    title: Text(
                      translation(context).yourLocation,
                      style: const TextStyle(color: constants.text, fontSize: 20),
                    ),
                  );
                } else {
                  return const ListTile();
                }
              },
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: constants.text,
                  ),
                  title: Text(
                    _suggestions[index].mainText,
                    style: const TextStyle(
                      color: constants.text,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_suggestions[index].secondaryText,
                      style: const TextStyle(color: constants.hint)),
                  onTap: () {
                    Navigator.pop(context,
                        ['place_id:${_suggestions[index].placeId}', _suggestions[index].mainText]);
                  },
                ),
              ),
            )
          ],
        ));
  }
}
