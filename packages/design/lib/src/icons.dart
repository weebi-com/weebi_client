import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'colors.dart';

/// Weebi object icons - semantic icons for articles, boutiques, contacts, etc.
abstract class IconsWeebi {
  static const articles = Icon(Icons.widgets, color: ColorsWeebi.orangeArticle);
  static const articlesIconData = Icons.widgets;
  static const articleCategories =
      Icon(Icons.format_list_bulleted, color: ColorsWeebi.orangeArticle);
  static const articlePhotos =
      Icon(Icons.image, color: ColorsWeebi.orangeArticle);
  static const storefront =
      Icon(Icons.store, color: ColorsWeebi.boutique);
  static const boutiqueIconData = Icons.storefront;
  static const contacts = Icon(Icons.contacts, color: ColorsWeebi.blueContact);
  static const contactsIconData = Icons.contacts;
  static const tickets = Icon(Icons.receipt, color: ColorsWeebi.greyTicket);
  static const ticketsIconData = Icons.receipt;
  static const firm = Icon(Icons.business);
  static const firmIconData = Icons.business;
  static const user = Icon(Icons.account_circle);
  static const chain = Icon(Icons.account_tree);
  static const scanBarcodeIcondata = FontAwesomeIcons.barcode;
  static const devices = Icon(Icons.important_devices);
  static const specialPermission = Icons.star;
  static const permissions = Icons.admin_panel_settings;
  static const stockManagement = Icons.warehouse;
  static const stockInventory = Icons.inventory_rounded;
  static const users = Icons.group;
  static const userAccess = Icons.fence;
  static const billingRights = Icons.account_balance;
  static const versement = Icons.playlist_add;
  static const spend = Icons.shopping_cart;

  static const tax = Icons.content_cut;
  static const promo = Icons.redeem;
  static const discount = Icons.redeem;
  static const address = Icons.location_city;

  static const versementClient =
      Icon(Icons.playlist_add, color: ColorsWeebi.blueSellCovered);
  static const versementFournisseur =
      Icon(Icons.playlist_add, color: ColorsWeebi.orangeSpendCover);

  /// Platform-aware device icon (mobile vs desktop). Uses defaultTargetPlatform
  /// for web compatibility (no dart:io).
  static Icon get deviceIcon =>
      defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS
          ? const Icon(Icons.smartphone)
          : const Icon(Icons.laptop);

  static const email = Icons.alternate_email;
  static const phone = Icons.call;
  static const cloudUploadIcon =
      Icon(Icons.system_security_update); // for download
}
