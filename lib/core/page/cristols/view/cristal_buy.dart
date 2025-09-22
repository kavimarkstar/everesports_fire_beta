import 'package:everesports/Theme/colors.dart';
import 'package:everesports/widget/common_elevated_button.dart';
import 'package:flutter/material.dart';

class CristalBuy extends StatefulWidget {
  const CristalBuy({super.key});

  @override
  State<CristalBuy> createState() => _CristalBuyState();
}

class _CristalBuyState extends State<CristalBuy> {
  List<String> items = ["100", "200", "300", "400", "500"];
  String? selectedItem;

  void onChanged(String? value) {
    setState(() {
      selectedItem = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[400]!,
                width: 0.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                borderRadius: BorderRadius.circular(12),

                isExpanded: true,
                dropdownColor: Theme.of(context).brightness == Brightness.dark
                    ? secondBlackColor
                    : mainWhiteColor,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? mainWhiteColor
                      : mainBlackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? mainWhiteColor
                      : mainBlackColor,
                ),
                items: items
                    .map(
                      (String item) => DropdownMenuItem(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 4.0,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? mainWhiteColor
                                  : mainBlackColor,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
                value: selectedItem,
                hint: Text(
                  "Select amount",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? mainWhiteColor
                        : mainBlackColor,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 70,
            width: double.infinity,

            child: commonElevatedButtonbuild(context, "Pay", () {}),
          ),
        ],
      ),
    );
  }
}
