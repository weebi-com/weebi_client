import 'package:flutter/material.dart';

class ExpansionChains extends StatefulWidget {
  const ExpansionChains({super.key});

  @override
  State<ExpansionChains> createState() => _ExpansionChainsState();
}

class _ExpansionChainsState extends State<ExpansionChains> {
  final ExpansionTileController controller = ExpansionTileController();
  var groupValue = 0;

  @override
  Widget build(BuildContext context) {
    void onChanged(int? val) {
      if (val != null) {
        setState(() {
          groupValue = val;
        });
      }
    }

    return ExpansionTile(
      leading: const Icon(Icons.factory),
      controller: controller,
      title: Text('Chain $groupValue'),
      children: <Widget>[
        for (final chain in List.generate(3, (int index) => index * 1))
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: RadioListTile(
              value: chain,
              title: Text('chain $chain'),
              groupValue: groupValue,
              onChanged: onChanged,
              controlAffinity: ListTileControlAffinity.platform,
            ),
          ),
      ],
    );
  }
}
