import 'package:halfways/helpers/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:halfways/language.dart';
import 'package:halfways/language_constants.dart';

import '../main.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: constants.mainBG,
        appBar: AppBar(
          toolbarHeight: 65,
          title: Text(
            translation(context).language,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 40,
              color: constants.accentColor,
            ),
          ),
          leadingWidth: 40,
          backgroundColor: constants.buttonBG,
        ),
        body: ListView.builder(
          itemCount: Language.languageList().length,
          itemBuilder: (BuildContext context, int index) {
            List<Language> languageList = Language.languageList();
            return ListTile(
              splashColor: Colors.transparent,
              onTap: () async {
                Locale locale = await setLocale(languageList[index].code);
                if (context.mounted) {
                  MyApp.setLocale(context, locale);
                  Navigator.pop(context);
                }
              },
              title: Text(
                languageList[index].name,
                style: const TextStyle(color: constants.text, fontSize: 18),
              ),
              tileColor: constants.hint,
            );
          },
        ));
  }
}
