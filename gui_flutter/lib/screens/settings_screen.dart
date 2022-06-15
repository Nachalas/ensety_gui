import 'package:ensety_windows_test/main.dart';
import 'package:ensety_windows_test/providers/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // Switch(
        //   value: _isOn,
        //   onChanged: (newVal) {
        //     setState(() {
        //       _isOn = newVal;
        //     });
        //   },
        //   activeColor: const Color.fromRGBO(36, 163, 165, 1),
        // ),
        TextButton(
          onPressed: () {
            MyApp.of(context)
                .setLocale(const Locale.fromSubtags(languageCode: 'ru'));
          },
          child: const Text('Russian'),
        ),
        TextButton(
          onPressed: () {
            MyApp.of(context)
                .setLocale(const Locale.fromSubtags(languageCode: 'en'));
          },
          child: const Text('English'),
        ),
        TextButton(
          onPressed: () {
            var prov = Provider.of<ThemeModel>(context, listen: false);
            prov.setTheme(!prov.isDark);
          },
          child: const Text('Change theme'),
        ),
      ]),
    );
  }
}
