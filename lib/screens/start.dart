import 'package:flutter/material.dart';
import 'package:pranayfunds/screens/settings.dart';

import 'home.dart';

class StartScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _bottommenu();
  }
}

class _bottommenu extends State<StartScreen>{
  var _pages= [Home(),Settings()];
  int _pageindex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Rose',
        debugShowCheckedModeBanner: false,
        home: Container(
          child: Scaffold(
            // appBar: AppBar(
            //   elevation: 0,
            // backgroundColor: Colors.transparent),
            body: _pages[_pageindex],
            bottomNavigationBar: BottomNavigationBar(
              items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),BottomNavigationBarItem(icon: Icon(Icons.settings), label: "settings")],
              currentIndex: _pageindex,
              onTap: (setValue){
                setState(() {
                  _pageindex=setValue;
                });
              },
            ),
          ),
        )
    );
  }

}