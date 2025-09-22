import 'package:everesports/core/page/cristols/view/cristal_buy.dart';
import 'package:everesports/core/page/cristols/widget/card.dart';
import 'package:flutter/material.dart';

class CristolsBuyPage extends StatefulWidget {
  const CristolsBuyPage({super.key});

  @override
  State<CristolsBuyPage> createState() => _CristolsBuyPageState();
}

class _CristolsBuyPageState extends State<CristolsBuyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cristols Buy")),
      body: Column(
        children: [
          CristolsCard(),
          Padding(padding: const EdgeInsets.all(20), child: CristalBuy()),
        ],
      ),
    );
  }
}
