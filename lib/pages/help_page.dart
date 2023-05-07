import 'package:flutter/material.dart';
import 'package:halfways/constants.dart' as constants;
import 'package:halfways/language_constants.dart';

import '../helper.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constants.mainBG,
      appBar: AppBar(
        toolbarHeight: 65,
        title: Text(
          translation(context).help,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 40,
            color: constants.accentColor,
          ),
        ),
        leadingWidth: 40,
        backgroundColor: constants.buttonBG,
      ),
      drawer: createDrawer(context, 1),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translation(context).howToTitle,
              style: const TextStyle(
                  color: constants.mainText, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              translation(context).howToText,
              style: const TextStyle(color: constants.mainText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
