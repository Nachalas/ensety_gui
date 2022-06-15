import 'dart:async';
import 'dart:io';

import 'package:ensety_windows_test/providers/backups.dart';
import 'package:ensety_windows_test/providers/jobs.dart';
import 'package:ensety_windows_test/providers/theme_model.dart';
import 'package:ensety_windows_test/screens/backup_log_screen.dart';
import 'package:ensety_windows_test/screens/settings_screen.dart';
import 'package:ensety_windows_test/screens/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:antdesign_icons/antdesign_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(800, 500);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = 'Ensety';
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale.fromSubtags(languageCode: 'en');

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) {
            return Jobs();
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            return Backups();
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            return ThemeModel();
          },
        ),
      ],
      child: Consumer(
        builder: (context, ThemeModel themeNotifier, child) {
          return MaterialApp(
            locale: _locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: themeNotifier.isDark ? ThemeData.dark() : ThemeData.light(),
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  PageController page = PageController();

  bool _toogleTrayIcon = true;

  Future<void> initSystemTray() async {
    String path = Platform.isWindows
        ? 'assets/images/app_icon.ico'
        : 'assets/app_icon.png';

    final menu = [
      MenuItem(label: 'Show', onClicked: _appWindow.show),
      MenuItem(label: 'Hide', onClicked: _appWindow.hide),
      MenuItem(label: 'Exit', onClicked: _appWindow.close),
    ];

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(
      title: "system tray",
      iconPath: path,
    );

    await _systemTray.setContextMenu(menu);

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {
        _systemTray.popUpContextMenu();
      } else if (eventName == "leftMouseDown") {
      } else if (eventName == "leftMouseUp") {
        _appWindow.show();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initSystemTray();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<SideMenuItem> items = [
      SideMenuItem(
        priority: 0,
        title: 'Dashboard',
        onTap: () => page.jumpToPage(0),
        icon: const Icon(AntIcons.pieChartOutlined),
      ),
      SideMenuItem(
        priority: 1,
        title: 'Tasks',
        onTap: () => page.jumpToPage(1),
        icon: const Icon(AntIcons.cloudServerOutlined),
      ),
      SideMenuItem(
        priority: 2,
        title: 'Browse backups',
        onTap: () => page.jumpToPage(2),
        icon: const Icon(AntIcons.calendarOutlined),
      ),
      SideMenuItem(
        priority: 3,
        title: 'Backup log',
        onTap: () => page.jumpToPage(3),
        icon: const Icon(AntIcons.fileDoneOutlined),
      ),
      SideMenuItem(
        priority: 4,
        title: 'Journal',
        onTap: () => page.jumpToPage(4),
        icon: const Icon(AntIcons.exceptionOutlined),
      ),
      SideMenuItem(
        priority: 5,
        title: 'Settings',
        onTap: () => page.jumpToPage(5),
        icon: const Icon(AntIcons.settingOutlined),
      ),
      // SideMenuItem(
      //   priority: 5,
      //   title: 'Exit',
      //   onTap: () {},
      //   icon: const Icon(Icons.exit_to_app),
      // ),
    ];

    return Scaffold(
      body: WindowBorder(
        color: Colors.grey,
        width: 1,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                      child: const Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          left: 12,
                        ),
                        child: Text(
                          'Ensety',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SideMenu(
                      controller: page,
                      title: Padding(
                        padding: const EdgeInsets.only(
                          left: 30.0,
                          top: 10,
                          bottom: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 50,
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            const Text(
                              'Ensety',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(24, 144, 255, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      items: items,
                      style: SideMenuStyle(
                        displayMode: SideMenuDisplayMode.open,
                        backgroundColor: Theme.of(context).bottomAppBarColor,
                        selectedTitleTextStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          //fontWeight: FontWeight.bold,
                        ),
                        unselectedTitleTextStyle: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                        selectedColor: Theme.of(context).backgroundColor,
                        //unselectedIconColor: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: PageView(
                      controller: page,
                      children: const [
                        Center(
                          child: Text('Dashboard'),
                        ),
                        TasksScreen(),
                        Center(
                          child: Text('Browse backups'),
                        ),
                        BackupLogScreen(),
                        Center(
                          child: Text('Journal'),
                        ),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
