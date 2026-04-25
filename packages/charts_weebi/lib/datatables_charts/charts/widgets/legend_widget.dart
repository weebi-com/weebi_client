// Flutter imports:
import 'package:flutter/material.dart';

class LegendWidget extends StatelessWidget {
  final String name;
  final Color color;
  final Icon icon;
  const LegendWidget(
      {super.key,
      required this.name,
      required this.color,
      this.icon = const Icon(
        Icons.ac_unit,
        color: Colors.transparent,
      )});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        icon,
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Color(0xff757391),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class LegendsListWidget extends StatelessWidget {
  final List<Legend> legends;

  const LegendsListWidget({
    super.key,
    required this.legends,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: legends
          .map(
            (e) => LegendWidget(
              name: e.name,
              color: e.color,
              icon: e.icon,
            ),
          )
          .toList(),
    );
  }
}

class Legend {
  final String name;
  final Color color;
  final Icon icon;
  const Legend(this.name, this.color,
      {this.icon = const Icon(
        Icons.ac_unit,
        color: Colors.transparent,
      )});
}
