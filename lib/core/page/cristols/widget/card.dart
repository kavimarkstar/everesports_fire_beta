import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';

class CristolsCard extends StatefulWidget {
  const CristolsCard({super.key});

  @override
  State<CristolsCard> createState() => _CristolsCardState();
}

class _CristolsCardState extends State<CristolsCard> {
  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 420,
        child: Card(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "EverEsports",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          Text("Cristols"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/image/chip-card.png", height: 45),
                          Image.asset(
                            "assets/image/wifi_mark_card.png",
                            height: 60,
                            color: isdark ? mainWhiteColor : mainBlackColor,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "4141 4500 4500 4500",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 5,
                          wordSpacing: 5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Kavimark"),
                          SizedBox(width: 10),
                          Column(
                            children: [
                              Text(
                                "12/25",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                          SizedBox(
                            width: 80,
                            height: 50,

                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: mainColor,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: secondColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
