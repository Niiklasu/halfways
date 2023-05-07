import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'constants.dart' as constants;

Widget createDrawer(BuildContext context, int position) {
  AppLocalizations local = AppLocalizations.of(context)!;
  List<List<dynamic>> pages = [
    [local.mainPage, Icons.location_on_outlined, '/home'],
    [local.help, Icons.help_outline, '/help'],
    [local.settings, Icons.settings_outlined, '/settings'],
    [local.contact, Icons.contact_page_outlined, '/contact']
  ];
  return Drawer(
    backgroundColor: constants.buttonBG,
    child: Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            children: [
              const SizedBox(width: 15),
              Image.asset(
                'assets/logos/icon_trimmed.png',
                width: 50,
              ),
              const SizedBox(width: 25),
              Text(
                local.appTitle,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 40,
                  color: constants.accentColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pages.length,
            itemBuilder: (BuildContext context, int index) => ListTile(
                splashColor: Colors.transparent,
                leading: Icon(pages[index][1], color: constants.mainText),
                title: Text(
                  pages[index][0],
                  style: const TextStyle(fontSize: 20, color: constants.mainText),
                ),
                tileColor: index == position ? constants.mainHint : null,
                onTap: () {
                  Navigator.pop(context);
                  if (ModalRoute.of(context)!.settings.name != pages[index][2]) {
                    Navigator.popAndPushNamed(context, pages[index][2]);
                  }
                }),
          ),
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Version: ${snapshot.data!.version}',
                      style: const TextStyle(color: constants.mainText),
                    ),
                  ),
                );
              default:
                return const SizedBox();
            }
          },
        ),
        const SizedBox(height: 20)
      ],
    ),
  );
}
