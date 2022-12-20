import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.popAndPushNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: SvgPicture.asset("lib/images/logo.svg",
                      height: 150,
                      width: 100,
                      semanticsLabel: 'SVG From asset folder.'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
