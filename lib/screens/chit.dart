import 'package:flutter/material.dart';
import 'package:pranayfunds/screens/settings.dart';

import 'home.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Bottommenu();
  }
}

class _Bottommenu extends State<StartScreen> {
  final _pages = [const Home(), const Settings()];
  int _pageindex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Rose',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          // appBar: AppBar(
          //   elevation: 0,
          // backgroundColor: Colors.transparent),
          body: _pages[_pageindex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "settings")
            ],
            currentIndex: _pageindex,
            onTap: (setValue) {
              setState(() {
                _pageindex = setValue;
              });
            },
          ),
        ));
  }
}
