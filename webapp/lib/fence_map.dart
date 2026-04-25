// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'core/constants/dimens.dart';

const List<MaterialColor> filtered = <MaterialColor>[
  Colors.indigo,
  Colors.blue,
//  Colors.lightBlue,
  // Colors.cyan,
  Colors.teal,
//  Colors.green,
  Colors.lightGreen,
  Colors.lime,
//  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.blueGrey,
];

class UserWidget extends StatelessWidget {
  final String userId;
  final String name;
  static const color = Colors.orange;
  const UserWidget({super.key, required this.userId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all((12)),
        color: color,
        child: Text(name),
      ),
    );
  }
}

const cc = <ChainWidget>[];
const uu = <UserWidget>[];
const btqs = <BoutiqueWidget>[];
const devicesW = <DeviceWidget>[];

class FirmWidget extends StatelessWidget {
  static const color = Colors.indigo;
  final Iterable<ChainWidget> chains;
  final Iterable<UserWidget> bosses;
  final String firmId;
  final String name;
  const FirmWidget({
    super.key,
    this.chains = cc,
    this.bosses = uu,
    required this.firmId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 3,
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: kDefaultPadding,
          spacing: kDefaultPadding,
          direction: Axis.horizontal,
          children: [
            Text(name),
            for (final boss in bosses) boss,
            for (final chain in chains) chain
          ],
        ),
      ),
    );
  }
}

class ChainWidget extends StatelessWidget {
  static const color = Colors.blue;
  final String chainId;
  final String name;
  final Iterable<BoutiqueWidget> boutiques;
  final Iterable<UserWidget> managers;
  const ChainWidget({
    super.key,
    required this.chainId,
    required this.name,
    this.boutiques = btqs,
    this.managers = uu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 3,
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: kDefaultPadding,
          spacing: kDefaultPadding,
          direction: Axis.horizontal,
          children: [
            Text(name),
            for (final manager in managers) manager,
            for (final boutique in boutiques) boutique,
          ],
        ),
      ),
    );
  }
}

class BoutiqueWidget extends StatelessWidget {
  static const color = Colors.teal;
  final String chainId;
  final String boutiqueId;
  final Iterable<DeviceWidget> devices;

  final String name;
  final Iterable<UserWidget> sellers;
  const BoutiqueWidget({
    super.key,
    required this.chainId,
    required this.boutiqueId,
    required this.name,
    this.sellers = uu,
    this.devices = devicesW,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: color,
        elevation: 3,
        child: SingleChildScrollView(
          child: Wrap(
            runSpacing: kDefaultPadding,
            spacing: kDefaultPadding,
            direction: Axis.horizontal,
            children: [
              Text(name),
              for (final seller in sellers) seller,
              for (final device in devices) device
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceWidget extends StatelessWidget {
  final String name;
  const DeviceWidget({this.name = '', super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Icon(Icons.point_of_sale),
    );
  }
}

class NestedWrapExample extends StatelessWidget {
  const NestedWrapExample({
    super.key,
    this.depth = 0,
    this.valuePrefix = '',
    this.color,
    this.onTap,
  });
  final void Function()? onTap;
  final int depth;
  final String valuePrefix;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return const FirmWidget(
      firmId: '1',
      name: 'Firm chez lili',
      bosses: [
        UserWidget(userId: '95', name: 'Lili the Boss'),
      ],
      chains: [
        ChainWidget(
          chainId: '11',
          name: 'Chain chez lili',
          boutiques: [
            BoutiqueWidget(
              boutiqueId: '111',
              chainId: '11',
              name: 'Boutique chez lili',
              sellers: [
                UserWidget(userId: '99', name: 'Sophie the Seller'),
              ],
              devices: [DeviceWidget(name: '')],
            )
          ],
        ),
        ChainWidget(
          chainId: '12',
          name: 'Chain ice cream',
          managers: [UserWidget(userId: '98', name: 'Michael the Manager')],
          boutiques: [
            BoutiqueWidget(
              chainId: '12',
              boutiqueId: '121',
              name: 'Boutique ice cream',
              sellers: [
                UserWidget(userId: '92', name: 'Sinatra Seller'),
              ],
              devices: [DeviceWidget(name: 'caisse par défaut')],
            ),
            BoutiqueWidget(
              chainId: '12',
              boutiqueId: '122',
              name: 'Boutique chocolat vanille',
              sellers: [
                UserWidget(userId: '91', name: 'Simba Seller'),
              ],
              devices: [DeviceWidget(name: 'caisse par défaut')],
            )
          ],
        )
      ],
    );
  }
}
