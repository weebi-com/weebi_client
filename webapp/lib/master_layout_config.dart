import 'package:design_weebi/design_weebi.dart' show IconsWeebi;
import 'package:flutter/material.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/views/widgets/portal_master_layout/sidebar.dart';

//import 'dart:math' as math;

final sidebarMenuConfigs = [
  SidebarMenuConfig(
    uri: RouteUri.dashboard,
    icon: Icons.dashboard_rounded,
    title: (context) => Lang.of(context).homePage,
  ),
  SidebarMenuConfig(
    uri: RouteUri.firmDetail,
    icon: Icons.business_rounded,
    title: (context) => Lang.of(context).menuFirm,
  ),
  SidebarMenuConfig(
    uri: RouteUri.listBoutique,
    icon: Icons.store_rounded,
    title: (context) => Lang.of(context).menuBoutiques,
  ),
  SidebarMenuConfig(
    uri: RouteUri.listUser,
    icon: Icons.group_rounded,
    title: (context) => Lang.of(context).menuUsers,
  ),
  SidebarMenuConfig(
    uri: RouteUri.listAccess,
    icon: Icons.admin_panel_settings_rounded,
    title: (context) => Lang.of(context).menuAccesses,
  ),
  SidebarMenuConfig(
    uri: RouteUri.listDevice,
    icon: Icons.devices_rounded,
    title: (context) => Lang.of(context).menuDevices,
  ),
  SidebarMenuConfig(
    uri: RouteUri.ticketsOverview,
    icon: IconsWeebi.ticketsIconData,
    title: (context) => Lang.of(context).menuTickets,
  ),
  SidebarMenuConfig(
    uri: RouteUri.billing,
    icon: Icons.credit_card_rounded,
    title: (context) => Lang.of(context).menuBilling,
  ),
  SidebarMenuConfig(
    uri: RouteUri.help,
    icon: Icons.help_outline_rounded,
    title: (context) => Lang.of(context).help,
  ),
  SidebarMenuConfig(
    uri: RouteUri.support,
    icon: Icons.support_agent_rounded,
    title: (context) => Lang.of(context).support,
  ),
  SidebarMenuConfig(
    uri: RouteUri.about,
    icon: Icons.info_outline_rounded,
    title: (context) => Lang.of(context).about,
  ),
];

const localeMenuConfigs = [
  LocaleMenuConfig(
    languageCode: 'fr',
    name: 'Français',
  ),
  LocaleMenuConfig(
    languageCode: 'en',
    name: 'English',
  ),
  LocaleMenuConfig(
    languageCode: 'zh',
    scriptCode: 'Hans',
    name: '中文 (简体)',
  ),
];
