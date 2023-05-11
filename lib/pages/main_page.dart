import 'package:halfways/helpers/drawer.dart';
import 'package:flutter/material.dart';
import 'package:halfways/language_constants.dart';
import 'package:halfways/pages/search_page.dart';
import 'route_page.dart';
import 'package:uuid/uuid.dart';
import '../helpers/constants.dart' as constants;

class Place {
  String id, name;
  Place(this.id, this.name);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<String> _modes = ['driving', /*'transit',*/ 'bicycling', 'walking'];

  int _selectedMode = 0;
  final _firstPlace = Place('', '');
  final _secondPlace = Place('', '');

  final _controllerFirst = TextEditingController();
  final _controllerSecond = TextEditingController();

  @override
  void dispose() {
    _controllerFirst.dispose();
    super.dispose();
  }

  TextField _buildAddressTextField(TextEditingController tec, String hint, Place place) {
    return TextField(
      controller: tec,
      readOnly: true,
      onTap: () async {
        final sessionToken = const Uuid().v4();
        List? result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SearchPage(sessionToken: sessionToken, hint: hint)));

        setState(() {
          tec.text = result != null ? result[1] : '';
          place.id = result != null ? result[0] : '';
          place.name = result != null ? result[1] : '';
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none),
        fillColor: constants.fill,
        filled: true,
        prefixIcon: const Icon(
          Icons.search_outlined,
          color: constants.hint,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(8),
        hintText: hint,
        hintStyle: const TextStyle(color: constants.hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constants.mainBG,
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          translation(context).appTitle,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 40,
            color: constants.accentColor,
          ),
        ),
        iconTheme: const IconThemeData(color: constants.text),
        leadingWidth: 40,
        backgroundColor: constants.buttonBG,
      ),
      drawer: createDrawer(context, 0),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ...List.generate(
                  _modes.length,
                  (index) => CircleAvatar(
                        radius: 30,
                        backgroundColor: constants.buttonBG,
                        child: IconButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: _selectedMode == index
                              ? Image.asset(
                                  'assets/icons/${_modes[index]}_filled.png',
                                  color: constants.accentColor,
                                )
                              : Image.asset(
                                  'assets/icons/${_modes[index]}.png',
                                  color: constants.text,
                                ),
                          onPressed: () {
                            setState(() {
                              _selectedMode = index;
                            });
                          },
                        ),
                      )),
            ]),
            const Spacer(flex: 3),
            _buildAddressTextField(_controllerFirst, translation(context).firstHint, _firstPlace),
            const Spacer(flex: 2),
            _buildAddressTextField(
                _controllerSecond, translation(context).secondHint, _secondPlace),
            const Spacer(flex: 30),
            ElevatedButton(
              onPressed: (_firstPlace.id != '' && _secondPlace.id != '')
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoutePage(
                            firstPlace: _firstPlace,
                            secondPlace: _secondPlace,
                            mode: _modes[_selectedMode],
                          ),
                        ),
                      );
                    }
                  : null,
              // onPressed: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => RoutePage(
              //               firstPlace: Place('place_id:ChIJIaGfee8tw4ARM6nKAHCUCVI', 'Pomona'),
              //               secondPlace:
              //                   Place('place_id:ChIJWdeZQOjKwoARqo8qxPo6AKE', 'Long Beach'),
              //               mode: _modes[_selectedMode],
              //             )),
              //   );
              // },
              style: ElevatedButton.styleFrom(
                backgroundColor: constants.buttonBG,
                foregroundColor: constants.accentColor,
                disabledBackgroundColor: constants.buttonBG,
                disabledForegroundColor: constants.hint,
                elevation: 3,
                minimumSize: const Size(150, 40),
              ),
              child: Text(translation(context).meetUp),
            ),
          ],
        ),
      ),
    );
  }
}
