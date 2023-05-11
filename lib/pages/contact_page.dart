import 'package:flutter/material.dart';
import 'package:halfways/helpers/constants.dart' as constants;
import 'package:halfways/language_constants.dart';

import '../helpers/drawer.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: constants.mainBG,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: constants.text),
        toolbarHeight: 65,
        title: Text(
          translation(context).contact,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 40,
            color: constants.accentColor,
          ),
        ),
        leadingWidth: 40,
        backgroundColor: constants.buttonBG,
      ),
      drawer: createDrawer(context, 3),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translation(context).disclaimerTitle,
              style:
                  const TextStyle(color: constants.text, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              translation(context).disclaimerText,
              style: const TextStyle(color: constants.text, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Text(
              translation(context).feedbackTitle,
              style:
                  const TextStyle(color: constants.text, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              translation(context).feedbackText,
              style: const TextStyle(color: constants.text, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Text(
              translation(context).imprint,
              style:
                  const TextStyle(color: constants.text, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'Niklas Unrau\n'
              'Moreller Weg 16\n'
              '52074 Aachen\n'
              'Germany\n\n'
              '${translation(context).phone}: +49 1520 5618085\n'
              '${translation(context).email}: unrau73.wu@gmail.com',
              style: const TextStyle(color: constants.text, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
