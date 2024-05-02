import 'package:flutter/foundation.dart';

import 'package:s5_demo_app/app.dart';
import 'package:s5_demo_app/view/file_system.dart';
import 'package:s5_demo_app/view/stream.dart';

void main() async {
  if (!kIsWeb) {
    S5.initDataPath('data/hive');
  }
  s5 = await S5.create(
    databaseEncryptionKey: Uint8List(32),
    autoConnectToNewNodes: false,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pages = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.folder_open),
      label: 'File System',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.rss_feed),
      label: 'E2EE Message Streams',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.more_horiz),
      label: 'More coming soon',
    ),
  ];

  int index = 1;

  @override
  Widget build(BuildContext context) {
    final Widget currentPage;
    if (index == 0) {
      currentPage = const FileSystemView();
    } else if (index == 1) {
      currentPage = const StreamView();
    } else {
      currentPage = Center(
        child: Text('Coming Soon'),
      );
    }
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      appBar: AppBar(
        title: Text('S5 Demo App (uses "s5" package for Dart/Flutter)'),
      ),
      body: isMobile
          ? currentPage
          : Row(
              children: [
                SizedBox(
                  width: 260,
                  child: Column(
                    children: [
                      for (final page in pages)
                        ListTile(
                          leading: page.icon,
                          title: Text(page.label!),
                          selected: pages.indexOf(page) == index,
                          onTap: () {
                            setState(() {
                              index = pages.indexOf(page);
                            });
                          },
                        )
                    ],
                  ),
                ),
                Expanded(child: currentPage),
              ],
            ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              items: [
                for (final page in pages) page,
              ],
              currentIndex: index,
              onTap: (i) {
                setState(() {
                  index = i;
                });
              },
            )
          : null,
    );
  }
}
