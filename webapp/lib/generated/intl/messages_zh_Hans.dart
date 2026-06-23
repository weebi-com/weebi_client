// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_Hans locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_Hans';

  static String m0(count) => "${Intl.plural(count, one: '按钮', other: '按钮')}";

  static String m1(count) => "${Intl.plural(count, one: '颜色', other: '颜色')}";

  static String m2(name) => "企业「${name}」已成功创建。";

  static String m3(count) => "${Intl.plural(count, one: '弹窗', other: '弹窗')}";

  static String m4(value) => "此字段必须与${value}相符";

  static String m5(count) => "${Intl.plural(count, one: '扩展', other: '扩展')}";

  static String m6(count) => "${Intl.plural(count, one: '表单', other: '表单')}";

  static String m7(max) => "此字段必须小于或等于${max}";

  static String m8(maxLength) => "此字段的长度必须小于或等于${maxLength}";

  static String m9(min) => "此字段必须大于或等于${min}";

  static String m10(minLength) => "此字段的长度必须大于或等于${minLength}";

  static String m11(count) => "${Intl.plural(count, one: '新订单', other: '新订单')}";

  static String m12(count) => "${Intl.plural(count, one: '新用户', other: '新用户')}";

  static String m13(value) => "此字段不得等于${value}";

  static String m14(count) => "${Intl.plural(count, one: '页面', other: '页面')}";

  static String m15(count) =>
      "${Intl.plural(count, one: '未决问题', other: '未决问题')}";

  static String m16(count) =>
      "${Intl.plural(count, one: '最新订单', other: '最新订单')}";

  static String m17(ticketId) => "小票详情 #${ticketId}";

  static String m18(count) => "${count} 项";

  static String m19(count) => "${Intl.plural(count, other: '# 张小票')}";

  static String m20(count) =>
      "${Intl.plural(count, one: 'UI 元素', other: 'UI 元素')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "aboutBlog": MessageLookupByLibrary.simpleMessage("博客"),
    "aboutPartners": MessageLookupByLibrary.simpleMessage("历史合作伙伴"),
    "account": MessageLookupByLibrary.simpleMessage("账户"),
    "adminPortalLogin": MessageLookupByLibrary.simpleMessage("管理后台登录"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("返回登入页面"),
    "billingAcceptEnterpriseTerms": MessageLookupByLibrary.simpleMessage(
      "我已阅读并同意企业版许可证的销售条款和条件。",
    ),
    "billingAcceptTermsToContinue": MessageLookupByLibrary.simpleMessage(
      "请先接受条款和条件。",
    ),
    "billingActionNotPermitted": MessageLookupByLibrary.simpleMessage(
      "您没有执行此操作的权限。",
    ),
    "billingAllUsersAlreadyAssigned": MessageLookupByLibrary.simpleMessage(
      "所有用户都已分配许可证。",
    ),
    "billingAssignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "将许可证分配给用户",
    ),
    "billingAssignSeats": MessageLookupByLibrary.simpleMessage("将许可证分配给用户"),
    "billingAssignSeatsCta": MessageLookupByLibrary.simpleMessage(
      "在“访问”中为用户分配您的新席位",
    ),
    "billingAttributedTo": MessageLookupByLibrary.simpleMessage("已分配给"),
    "billingLicenses": MessageLookupByLibrary.simpleMessage("许可证"),
    "billingLifetime": MessageLookupByLibrary.simpleMessage("终身"),
    "billingMyLicenses": MessageLookupByLibrary.simpleMessage("我的许可证"),
    "billingNoAccess": MessageLookupByLibrary.simpleMessage(
      "您没有管理许可证的权限。请联系企业管理员为您开通账单相关权限。",
    ),
    "billingNoUsersAvailable": MessageLookupByLibrary.simpleMessage(
      "没有可分配的用户。请先在「用户」中添加用户。",
    ),
    "billingNotYetAttributed": MessageLookupByLibrary.simpleMessage("尚未分配"),
    "billingPaymentProcessing": MessageLookupByLibrary.simpleMessage(
      "付款已收到。我们正在与 Stripe 确认 — 您的许可证将很快显示。如未显示，请检查 webhook 配置。",
    ),
    "billingPaymentSuccess": MessageLookupByLibrary.simpleMessage(
      "您的付款已接受。您现已拥有有效许可证。",
    ),
    "billingPerUser": MessageLookupByLibrary.simpleMessage("每位用户"),
    "billingPlanEntreprise": MessageLookupByLibrary.simpleMessage("Weebi 企业版"),
    "billingPlanPremium": MessageLookupByLibrary.simpleMessage("Weebi 高级版"),
    "billingPurchase": MessageLookupByLibrary.simpleMessage("购买"),
    "billingPurchaseLicense": MessageLookupByLibrary.simpleMessage("购买许可证"),
    "billingPurchaseLicenseDescription": MessageLookupByLibrary.simpleMessage(
      "选择许可证即可使用 Weebi 的高级功能。每个席位为一次性购买：不设到期，也不是订阅——无需续费，没有倒计时。",
    ),
    "billingReassignNoOtherUser": MessageLookupByLibrary.simpleMessage(
      "没有其他用户可接收此席位。请先添加用户或在其他位置释放一个席位。",
    ),
    "billingReassignSeat": MessageLookupByLibrary.simpleMessage("重新分配"),
    "billingReassignSeatDialogTitle": MessageLookupByLibrary.simpleMessage(
      "将此许可证席位重新分配给其他用户",
    ),
    "billingRetry": MessageLookupByLibrary.simpleMessage("重试"),
    "billingSeatsAttributed": MessageLookupByLibrary.simpleMessage("许可证已分配"),
    "billingUsers": MessageLookupByLibrary.simpleMessage("用户"),
    "billingValidUntil": MessageLookupByLibrary.simpleMessage("有效期至"),
    "billingViewFullTerms": MessageLookupByLibrary.simpleMessage("在新标签页查看完整文档"),
    "buttonEmphasis": MessageLookupByLibrary.simpleMessage("按钮强调"),
    "buttons": m0,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "changeProfilePhoto": MessageLookupByLibrary.simpleMessage("更换照片"),
    "closeNavigationMenu": MessageLookupByLibrary.simpleMessage("关闭导航菜单"),
    "colorPalette": MessageLookupByLibrary.simpleMessage("调色板"),
    "colorScheme": MessageLookupByLibrary.simpleMessage("配色方案"),
    "colors": m1,
    "confirmDeleteRecord": MessageLookupByLibrary.simpleMessage("确定删除此记录？"),
    "confirmSubmitRecord": MessageLookupByLibrary.simpleMessage("确定提交此记录？"),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "createEnterpriseErrorPrefix": MessageLookupByLibrary.simpleMessage(
      "创建企业时出错：",
    ),
    "createEnterprisePageTitle": MessageLookupByLibrary.simpleMessage("创建企业"),
    "createEnterpriseSuccessTitle": m2,
    "creditCardErrorText": MessageLookupByLibrary.simpleMessage(
      "此字段需要有效的信用卡号码。",
    ),
    "crudBack": MessageLookupByLibrary.simpleMessage("返回"),
    "crudDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "crudDetail": MessageLookupByLibrary.simpleMessage("详情"),
    "crudNew": MessageLookupByLibrary.simpleMessage("创建"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("深色主题"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "dashboardCardBoutiquesValue": MessageLookupByLibrary.simpleMessage("我的门店"),
    "dashboardCardDevicesValue": MessageLookupByLibrary.simpleMessage("设备"),
    "dashboardCardMyFirmValue": MessageLookupByLibrary.simpleMessage("我的企业"),
    "dashboardCardTicketsShort": MessageLookupByLibrary.simpleMessage("小票"),
    "dashboardCardTicketsToday": MessageLookupByLibrary.simpleMessage("今日小票"),
    "dashboardCardUserAccess": MessageLookupByLibrary.simpleMessage("用户权限"),
    "dashboardCardUsersValue": MessageLookupByLibrary.simpleMessage("用户"),
    "dateStringErrorText": MessageLookupByLibrary.simpleMessage(
      "此字段需要有效的日期字符串。",
    ),
    "dialogs": m3,
    "dontHaveAnAccount": MessageLookupByLibrary.simpleMessage("还未有账户？"),
    "email": MessageLookupByLibrary.simpleMessage("电子邮件地址"),
    "emailErrorText": MessageLookupByLibrary.simpleMessage("此字段需要有效的电子邮件地址。"),
    "enterpriseNameFieldHint": MessageLookupByLibrary.simpleMessage("企业名称"),
    "enterpriseNameFieldLabel": MessageLookupByLibrary.simpleMessage("企业"),
    "equalErrorText": m4,
    "error404": MessageLookupByLibrary.simpleMessage("404 错误"),
    "error404Message": MessageLookupByLibrary.simpleMessage(
      "很抱歉，你正在寻找的页面不存在或已经被移除。",
    ),
    "error404Title": MessageLookupByLibrary.simpleMessage("找不到页面"),
    "example": MessageLookupByLibrary.simpleMessage("例子"),
    "extensions": m5,
    "firmCardDescription": MessageLookupByLibrary.simpleMessage(
      "企业汇总您的用户与门店/连锁。",
    ),
    "firmErrorCreateHint": MessageLookupByLibrary.simpleMessage(
      "请点击「添加企业」按钮创建新企业。",
    ),
    "firmErrorUnexpected": MessageLookupByLibrary.simpleMessage("发生意外错误。"),
    "firmPageTitle": MessageLookupByLibrary.simpleMessage("我的企业"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("忘记密码？"),
    "forgotPasswordMessage": MessageLookupByLibrary.simpleMessage(
      "输入您的电子邮件地址，我们将向您发送重置密码的链接。",
    ),
    "forgotPasswordTitle": MessageLookupByLibrary.simpleMessage("重置您的密码"),
    "forms": m6,
    "generalUi": MessageLookupByLibrary.simpleMessage("常规 UI"),
    "help": MessageLookupByLibrary.simpleMessage("帮助"),
    "helpReadFaq": MessageLookupByLibrary.simpleMessage("阅读常见问题"),
    "helpResourcesTitle": MessageLookupByLibrary.simpleMessage("资源"),
    "helpScopeBody": MessageLookupByLibrary.simpleMessage(
      "Web控制台可管理票据（查看、筛选、搜索）。文章、联系人和操作（销售、采购、库存移动等）目前仅在移动应用中可用。",
    ),
    "helpScopeTitle": MessageLookupByLibrary.simpleMessage("我可以在Web控制台做什么？"),
    "helpWatchDemos": MessageLookupByLibrary.simpleMessage("观看视频演示"),
    "hi": MessageLookupByLibrary.simpleMessage("您好"),
    "homePage": MessageLookupByLibrary.simpleMessage("首页"),
    "iframeDemo": MessageLookupByLibrary.simpleMessage("IFrame 演示"),
    "integerErrorText": MessageLookupByLibrary.simpleMessage("此字段需要有效的整数。"),
    "ipErrorText": MessageLookupByLibrary.simpleMessage("此字段需要有效的IP。"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "legalDocTitleCgvFr": MessageLookupByLibrary.simpleMessage(
      "Conditions Générales de Vente",
    ),
    "legalDocTitleTermsEn": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions of Sale",
    ),
    "legalDocumentVersionId": MessageLookupByLibrary.simpleMessage("文档版本编号"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("亮色主题"),
    "login": MessageLookupByLibrary.simpleMessage("登入"),
    "loginNow": MessageLookupByLibrary.simpleMessage("马上登入！"),
    "logout": MessageLookupByLibrary.simpleMessage("登出"),
    "loremIpsum": MessageLookupByLibrary.simpleMessage(
      "这时候风雨也停止进行曲的合奏，四方云集，由何处开始",
    ),
    "matchErrorText": MessageLookupByLibrary.simpleMessage("此字段与格式不匹配。"),
    "maxErrorText": m7,
    "maxLengthErrorText": m8,
    "menuAccesses": MessageLookupByLibrary.simpleMessage("访问"),
    "menuBilling": MessageLookupByLibrary.simpleMessage("Weebi 许可证"),
    "menuBoutiques": MessageLookupByLibrary.simpleMessage("店铺"),
    "menuDevices": MessageLookupByLibrary.simpleMessage("设备"),
    "menuFirm": MessageLookupByLibrary.simpleMessage("我的企业"),
    "menuScopeDisclaimer": MessageLookupByLibrary.simpleMessage(
      "文章、联系人和操作（销售、采购、库存移动等）目前仅在移动应用中可用。",
    ),
    "menuStats": MessageLookupByLibrary.simpleMessage("统计数据"),
    "menuTickets": MessageLookupByLibrary.simpleMessage("票据"),
    "menuUsers": MessageLookupByLibrary.simpleMessage("用户"),
    "minErrorText": m9,
    "minLengthErrorText": m10,
    "myProfile": MessageLookupByLibrary.simpleMessage("我的个人资料"),
    "newOrders": m11,
    "newUsers": m12,
    "notEqualErrorText": m13,
    "numericErrorText": MessageLookupByLibrary.simpleMessage("此字段必须是数字。"),
    "openInNewTab": MessageLookupByLibrary.simpleMessage("在新标签打开"),
    "operationalLicenseBlockedBody": MessageLookupByLibrary.simpleMessage(
      "请让企业管理员为您分配有效的许可证席位，或使用企业创建者账号登录，然后才能使用小票、文章与联系人。若您负责许可证与计费，请前往「计费」。",
    ),
    "operationalLicenseBlockedTitle": MessageLookupByLibrary.simpleMessage(
      "需要有效的许可证席位",
    ),
    "operationalLicenseOpenBilling": MessageLookupByLibrary.simpleMessage("计费"),
    "operationalLicenseRetry": MessageLookupByLibrary.simpleMessage("重试"),
    "pages": m14,
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "passwordNotMatch": MessageLookupByLibrary.simpleMessage("密码不匹配。"),
    "passwordResetEmailSent": MessageLookupByLibrary.simpleMessage(
      "如果此电子邮件有对应账户，您将收到重置密码的链接。",
    ),
    "pendingIssues": m15,
    "recentOrders": m16,
    "recordDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "记录已成功删除。",
    ),
    "recordSavedSuccessfully": MessageLookupByLibrary.simpleMessage("记录已成功保存。"),
    "recordSubmittedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "记录已成功提交。",
    ),
    "refreshAction": MessageLookupByLibrary.simpleMessage("刷新"),
    "register": MessageLookupByLibrary.simpleMessage("注册"),
    "registerANewAccount": MessageLookupByLibrary.simpleMessage("注册新账户"),
    "registerNow": MessageLookupByLibrary.simpleMessage("现在就注册！"),
    "requiredErrorText": MessageLookupByLibrary.simpleMessage("此字段不能为空。"),
    "retypePassword": MessageLookupByLibrary.simpleMessage("重新输入密码"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "statsAll": MessageLookupByLibrary.simpleMessage("全部"),
    "statsMetricAllIncome": MessageLookupByLibrary.simpleMessage("总收入"),
    "statsMetricAllSpending": MessageLookupByLibrary.simpleMessage("总支出"),
    "statsMetricCashflowIncome": MessageLookupByLibrary.simpleMessage("现金流入"),
    "statsMetricCashflowSpending": MessageLookupByLibrary.simpleMessage("现金流出"),
    "statsNoDataAvailable": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "statsPeriodDay": MessageLookupByLibrary.simpleMessage("日"),
    "statsPeriodMonth": MessageLookupByLibrary.simpleMessage("月"),
    "statsPeriodWeek": MessageLookupByLibrary.simpleMessage("周"),
    "statsSelectBoutiques": MessageLookupByLibrary.simpleMessage("选择门店："),
    "statsStackedByBoutique": MessageLookupByLibrary.simpleMessage("按门店堆叠"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "support": MessageLookupByLibrary.simpleMessage("支持"),
    "supportChatWhatsApp": MessageLookupByLibrary.simpleMessage("与Weebi支持聊天"),
    "supportEmailUs": MessageLookupByLibrary.simpleMessage("给我们发邮件"),
    "text": MessageLookupByLibrary.simpleMessage("文字"),
    "textEmphasis": MessageLookupByLibrary.simpleMessage("文字强调"),
    "textTheme": MessageLookupByLibrary.simpleMessage("文字主题"),
    "ticketDetailTitle": m17,
    "ticketItemsShort": m18,
    "ticketNotProvided": MessageLookupByLibrary.simpleMessage("未提供小票"),
    "ticketTypeDefault": MessageLookupByLibrary.simpleMessage("小票"),
    "ticketsBoutiqueAll": MessageLookupByLibrary.simpleMessage("全部门店"),
    "ticketsBoutiqueFallback": MessageLookupByLibrary.simpleMessage("门店"),
    "ticketsChainUnavailable": MessageLookupByLibrary.simpleMessage("连锁不可用"),
    "ticketsColumnAmount": MessageLookupByLibrary.simpleMessage("金额"),
    "ticketsColumnBoutique": MessageLookupByLibrary.simpleMessage("门店"),
    "ticketsColumnContact": MessageLookupByLibrary.simpleMessage("联系人"),
    "ticketsColumnDateAndNumber": MessageLookupByLibrary.simpleMessage(
      "日期 · 编号",
    ),
    "ticketsColumnType": MessageLookupByLibrary.simpleMessage("类型"),
    "ticketsCount": m19,
    "ticketsDateAll": MessageLookupByLibrary.simpleMessage("全部日期"),
    "ticketsDeletedChip": MessageLookupByLibrary.simpleMessage("已删除"),
    "ticketsDeletedExclude": MessageLookupByLibrary.simpleMessage("未删除"),
    "ticketsDeletedOnly": MessageLookupByLibrary.simpleMessage("仅已删除"),
    "ticketsEmpty": MessageLookupByLibrary.simpleMessage("暂无小票"),
    "ticketsFiltersTitle": MessageLookupByLibrary.simpleMessage("筛选"),
    "ticketsGroupByBoutique": MessageLookupByLibrary.simpleMessage("按门店分组"),
    "ticketsPaymentCard": MessageLookupByLibrary.simpleMessage("银行卡"),
    "ticketsPaymentCash": MessageLookupByLibrary.simpleMessage("现金"),
    "ticketsPaymentCheque": MessageLookupByLibrary.simpleMessage("支票"),
    "ticketsPaymentCredit": MessageLookupByLibrary.simpleMessage("赊账"),
    "ticketsPaymentGoods": MessageLookupByLibrary.simpleMessage("货品"),
    "ticketsPaymentMobileMoney": MessageLookupByLibrary.simpleMessage("移动支付"),
    "ticketsPaymentUnknown": MessageLookupByLibrary.simpleMessage("—"),
    "ticketsSeatEntitlementSubtitle": MessageLookupByLibrary.simpleMessage(
      "需要有效的许可证席位",
    ),
    "ticketsSeatGatedBoutiqueViewsDetail": MessageLookupByLibrary.simpleMessage(
      "按门店筛选与分组需要有效的许可证席位。企业创建者可无席位使用核心同步（预览）；此视图仅面向已分配席位的成员。请前往「计费」或请管理员为您分配席位。",
    ),
    "ticketsSeatGatedBoutiqueViewsTitle": MessageLookupByLibrary.simpleMessage(
      "按门店筛选与分组",
    ),
    "ticketsSortChronological": MessageLookupByLibrary.simpleMessage("按时间排序"),
    "ticketsStatusActive": MessageLookupByLibrary.simpleMessage("有效"),
    "ticketsStatusAll": MessageLookupByLibrary.simpleMessage("全部"),
    "ticketsStatusInactive": MessageLookupByLibrary.simpleMessage("无效"),
    "ticketsTooltipClearDates": MessageLookupByLibrary.simpleMessage("全部日期"),
    "ticketsTooltipFilterBoutique": MessageLookupByLibrary.simpleMessage(
      "按门店筛选",
    ),
    "ticketsTooltipFilterByStatus": MessageLookupByLibrary.simpleMessage(
      "按状态筛选",
    ),
    "ticketsTooltipFilterDeleted": MessageLookupByLibrary.simpleMessage(
      "按已删除小票筛选",
    ),
    "ticketsTooltipRefresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "todaySales": MessageLookupByLibrary.simpleMessage("今日销售额"),
    "typography": MessageLookupByLibrary.simpleMessage("排版"),
    "uiElements": m20,
    "urlErrorText": MessageLookupByLibrary.simpleMessage("此字段需要有效的URL地址。"),
    "username": MessageLookupByLibrary.simpleMessage("用户名"),
    "yes": MessageLookupByLibrary.simpleMessage("是的"),
  };
}
