import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pranayfunds/screens/start.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffffffff), Color(0xffEFF1F5)],
              stops: [0, 1])),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StartScreen()));
                        },
                      ),
                      // SizedBox(
                      //   child: SvgPicture.asset("lib/images/settings.svg",
                      //       height: 30,
                      //       width: 20,
                      //       semanticsLabel: 'SVG From asset folder.'),
                      // )
                    ],
                  ),
                  // Round Acvatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      "lib/images/avatar.png",
                      fit: BoxFit.cover,
                      height: 80,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Pranay Kiran",
                    style: TextStyle(
                        color: Color(0xff000000),
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // menu row
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "STATS",
                          style: TextStyle(
                              color: Color(0xff587EFF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "ACHIEVEMENTS",
                          style: TextStyle(
                              color: Color(0xff9E9FA1),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "ACTIVITY",
                          style: TextStyle(
                              color: Color(0xff9E9FA1),
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // two cards row
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // card 1
                        Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                              color: const Color(0xffFFFFFF),
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    child: SvgPicture.asset(
                                        "lib/images/flash.svg",
                                        height: 40,
                                        color: const Color(0xffFF4080),
                                        semanticsLabel:
                                            'SVG From asset folder.'),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "55",
                                        style: TextStyle(
                                            color: Color(0xff000000),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        "Withdrals",
                                        style: TextStyle(
                                            color: Color(0xff9E9FA1),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        // card 2
                        Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                              color: const Color(0xffFFFFFF),
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    child: SvgPicture.asset(
                                        "lib/images/flash.svg",
                                        height: 40,
                                        color: const Color(0xffFF4080),
                                        semanticsLabel:
                                            'SVG From asset folder.'),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "105",
                                        style: TextStyle(
                                            color: Color(0xff000000),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        "Credits",
                                        style: TextStyle(
                                            color: Color(0xff9E9FA1),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // small heading
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "ACHIEVEMENTS",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0xff9098A3),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // A big card
                  Container(
                    height: 300,
                    width: 320,
                    decoration: BoxDecoration(
                        color: const Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(20)),
                    child: SizedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "lib/images/badge.png",
                          height: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          )),
    );
  }
}
