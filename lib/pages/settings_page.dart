import 'package:flutter/material.dart';
import 'package:halfways/helpers/constants.dart' as constants;
import 'package:halfways/language_constants.dart';
import 'package:halfways/pages/language_page.dart';

import '../helpers/drawer.dart';
import '../language.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constants.mainBG,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: constants.text),
        toolbarHeight: 65,
        title: Text(
          translation(context).settings,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 40,
            color: constants.accentColor,
          ),
        ),
        leadingWidth: 40,
        backgroundColor: constants.buttonBG,
      ),
      drawer: createDrawer(context, 2),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          ListTile(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const LanguagePage()));
            },
            tileColor: constants.hint,
            title: Row(
              children: [
                Text(
                  translation(context).language,
                  style: const TextStyle(color: constants.text, fontSize: 18),
                ),
                const Spacer(),
                FutureBuilder(
                  future: getLocale(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(
                        Language.languageList()
                            .firstWhere((language) => language.code == snapshot.data!.languageCode)
                            .name,
                        style: const TextStyle(color: constants.accentColor, fontSize: 18),
                      );
                    }
                    return const SizedBox();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
