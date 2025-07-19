import 'package:flutter/material.dart';
import 'package:pranayfunds/screens/chit.dart';
import 'package:pranayfunds/screens/investments.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //welcome
                const Padding(
                  padding: EdgeInsets.only(top: 54.0, bottom: 15.0, left: 25.0),
                  child: Text(
                    'Welcome,',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color(0xff171930),
                        fontFamily: 'Inter',
                        fontSize: 31,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.2592592592592593),
                  ),
                ),

                //card
                SizedBox(
                  height: 235,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xff654EA3), Color(0xffEAAFC8)],
                              stops: [0.40, 1])),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.only(top: 32.0, left: 32.0),
                              child: Stack(
                                children: [
                                  // image
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: SizedBox(
                                              height: 37,
                                              width: 37,
                                              child:
                                                  // Round Acvatar
                                                  ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: Image.asset(
                                                  "lib/images/avatar.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Heading
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Pranay Kiran',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(0xffffffff),
                                                    fontFamily: 'Inter',
                                                    fontSize: 21,
                                                    letterSpacing: 0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1.2592592592592593),
                                              ),
                                              // sub heading
                                              Text(
                                                'Rs. 17,00,500',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(0xffffffff),
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                    letterSpacing: 0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1.2941176470588236),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      //Bottom Text
                                      const Padding(
                                        padding: EdgeInsets.only(top: 102),
                                        child: Text('PRANAY FUNDS',
                                            style: TextStyle(
                                                color: Color(0xffffffff),
                                                fontFamily: 'Inter',
                                                fontSize: 26,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.bold,
                                                height: 1)),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // card heading
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Schemes',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color(0xff171930),
                        fontFamily: 'Inter',
                        fontSize: 21,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.2592592592592593),
                  ),
                ),

                // 2nd card
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox(
                    height: 170,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xffffffff),
                      ),
                      child: Column(children: [
                        TextButton(
                          onPressed: (() => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Investments()))
                              }),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, top: 20.0),
                                child: Row(children: [
                                  SizedBox(
                                    height: 37,
                                    width: 37,
                                    // png picture
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(
                                          "lib/images/investment.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Investments',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                      // sub text
                                      Text(
                                        'Gross Value',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1.2941176470588236),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 20.0, top: 20.0),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 11),
                                  child: Row(children: [
                                    Text(
                                      'Rs. 12,00,000',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xff171930),
                                          fontFamily: 'Inter',
                                          fontSize: 17,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.normal,
                                          height: 1),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xff171930),
                                      size: 15,
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2nd row
                        TextButton(
                          onPressed: (() => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Chits()))
                              }),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, top: 20.0),
                                child: Row(children: [
                                  SizedBox(
                                    height: 37,
                                    width: 37,
                                    // png picture
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(
                                          "lib/images/bag.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chit Funds',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                      // sub text
                                      Text(
                                        'Gross Value',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1.2941176470588236),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 20.0, top: 20.0),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 11),
                                  child: Row(children: [
                                    Text(
                                      'Rs. 70,000',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Color(0xff171930),
                                          fontFamily: 'Inter',
                                          fontSize: 17,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.normal,
                                          height: 1),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xff171930),
                                      size: 15,
                                    )
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  ),
                ),

                // card heading
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Add Funds',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color(0xff171930),
                        fontFamily: 'Inter',
                        fontSize: 21,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.2592592592592593),
                  ),
                ),

                // 3rd card
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox(
                    height: 250,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xffffffff),
                      ),
                      child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20.0, left: 20.0),
                              child: Text(
                                'BANK TRANSFER',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xff171930),
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2592592592592593),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.0, top: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Account No.',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                      // sub text
                                      Text(
                                        'IFSC Code',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1.2941176470588236),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.0, top: 20.0),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '7613049198',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Color(0xff171930),
                                              fontFamily: 'Inter',
                                              fontSize: 17,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                              height: 1),
                                        ),
                                        // sub text
                                        Text(
                                          'KKBK0007475',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Color(0xff171930),
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                              height: 1.2941176470588236),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 2nd row
                            Padding(
                              padding: EdgeInsets.only(top: 40.0, left: 20.0),
                              child: Text(
                                'UPI TRANSFER',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xff171930),
                                    fontFamily: 'Inter',
                                    fontSize: 17,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2592592592592593),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.0, top: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UPI Id.',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xff171930),
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.0, top: 20.0),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'kiranpranay12@okicici',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: Color(0xff171930),
                                              fontFamily: 'Inter',
                                              fontSize: 17,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                              height: 1),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ]),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
