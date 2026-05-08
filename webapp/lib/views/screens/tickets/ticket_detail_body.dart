import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/money/money_formatting.dart';
import 'package:web_admin/providers/tickets_boutique_cache.dart';
import 'package:web_admin/views/screens/tickets/ticket_type_ui_ext.dart';

const _rowPadding = SizedBox(width: 28);

String _formatLineQuantity(double q, Locale locale) {
  final nf = NumberFormat.decimalPattern(locale.toString());
  nf.minimumFractionDigits = 0;
  nf.maximumFractionDigits = q == q.roundToDouble() ? 0 : 4;
  return nf.format(q);
}

/// Rich ticket detail view inspired by weebi_app TicketDetailWidget.
/// Displays items with prices/costs, totals (HT, promo, taxes, TTC), contact, etc.
class TicketDetailBody extends StatelessWidget {
  final TicketPb ticket;
  final TicketsBoutiqueCache? boutiqueCache;

  const TicketDetailBody({
    super.key,
    required this.ticket,
    this.boutiqueCache,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final billingIso =
        boutiqueCache?.getBillingCurrency(ticket.counterfoil.boutiqueId);
    final effectiveIso = (billingIso != null && billingIso.length == 3)
        ? billingIso
        : MoneyFormatting.fallbackIso;
    final numFormat = NumberFormat.currency(
      locale: locale.toString(),
      name: effectiveIso,
    );
    final fxRateCaption = MoneyFormatting.formatFxSnapshotCaption(
      ticket: ticket,
      boutiqueIso4217: effectiveIso,
      locale: locale,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final cf = ticket.counterfoil;

    final boutiqueName = _getBoutiqueDisplayName(cf);
    final boutiqueIcon = _getBoutiqueIcon(cf);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        // Boutique / counterfoil
        if (boutiqueName.isNotEmpty) ...[
          _InfoRow(
            icon: Icons.storefront,
            leadingWidget: boutiqueIcon,
            child: Text(boutiqueName),
          ),
          if (cf.chainName.isNotEmpty)
            _InfoRow(icon: Icons.link, child: Text(cf.chainName)),
          const Divider(),
        ],
        // Date & time
        _InfoRow(
          icon: Icons.schedule,
          iconColor: ticket.ticketType.iconColor,
          child: Text(
            _formatDateTime(ticket.date, ticket.creationDate, dateFormat, timeFormat),
          ),
        ),
        if (ticket.date != ticket.creationDate && ticket.creationDate.isNotEmpty)
          _InfoRow(
            icon: Icons.event,
            iconColor: ticket.ticketType.iconColor,
            child: Text(
              '${dateFormat.format(DateTime.tryParse(ticket.creationDate) ?? DateTime.now())} '
              '${timeFormat.format(DateTime.tryParse(ticket.creationDate) ?? DateTime.now())} (création)',
            ),
          ),
        // Ticket ID
        _InfoRow(
          icon: IconsWeebi.ticketsIconData,
          iconColor: ticket.ticketType.iconColor,
          child: Text('#${ticket.nonUniqueId}'),
        ),
        // Ticket type
        _InfoRow(
          leadingWidget: ticket.ticketType.icon,
          icon: ticket.ticketType.iconData,
          iconColor: ticket.ticketType.iconColor,
          child: Text(_ticketTypeLabel(ticket.ticketType)),
        ),
        // Payment type (financial only)
        if (ticket.ticketType.isFinancial)
          _InfoRow(
            icon: _paymentIcon(ticket.paymentType),
            iconColor: ticket.ticketType.iconColor,
            child: Text('Paiement : ${_paymentLabel(ticket.paymentType.name)}'),
          ),
        const Divider(),
        // Items
        for (final item in ticket.items)
          _ItemRow(
            ticketType: ticket.ticketType,
            item: item,
            numFormat: numFormat,
            locale: locale,
          ),
        // Totals (non-stock types)
        if (!TicketTypePbLogic.stockTypes.contains(ticket.ticketType)) ...[
          _TotalRow(
            icon: Icons.title,
            iconColor: ticket.ticketType.iconColor,
            label: 'Total articles',
            value: _getTotalItemsFormatted(ticket, numFormat),
          ),
          if (ticket.promo != 0)
            _TotalRow(
              icon: Icons.redeem,
              iconColor: ticket.ticketType.iconColor,
              label: 'Promo : ${numFormat.format(ticket.promo)}%',
              value: _getPromoFormatted(ticket, numFormat),
            ),
          if (ticket.discountAmount != 0)
            _TotalRow(
              icon: Icons.redeem,
              iconColor: ticket.ticketType.iconColor,
              label: 'Réduction',
              value: '- ${numFormat.format(ticket.discountAmount)}',
            ),
          if (ticket.taxe.percentage != 0.0 &&
              (ticket.promo != 0 || ticket.discountAmount != 0))
            _TotalRow(
              icon: Icons.calculate,
              iconColor: ticket.ticketType.iconColor,
              label: 'Total HT',
              value: _getTaxExcludedFormatted(ticket, numFormat),
            ),
          if (ticket.taxe.name != 'HT 0%' && ticket.taxe.name.isNotEmpty)
            _TotalRow(
              icon: Icons.percent,
              iconColor: ticket.ticketType.iconColor,
              label: 'Taxes',
              value: _getTaxesFormatted(ticket, numFormat),
            ),
          _TotalRow(
            icon: Icons.text_fields,
            iconColor: ticket.ticketType.iconColor,
            label: 'Total TTC',
            value: MoneyFormatting.formatTicketAmountLine(
              localAmount: ticket.totalComputed,
              boutiqueIso4217: effectiveIso,
              ticket: ticket,
              locale: locale,
            ),
            bold: true,
          ),
          if (fxRateCaption != null)
            _InfoRow(
              icon: Icons.currency_exchange,
              iconColor: ticket.ticketType.iconColor,
              child: Text(
                "À l'émission du ticket : $fxRateCaption",
              ),
            ),
          const Divider(),
          if (ticket.ticketType.isFinancial) ...[
            _TotalRow(
              icon: Icons.arrow_downward,
              iconColor: ticket.ticketType.iconColor,
              label: ticket.ticketType.isPrice
                  ? 'Montant donné par le client'
                  : 'Donné au fournisseur',
              value: MoneyFormatting.formatTicketAmountLine(
                localAmount: ticket.received,
                boutiqueIso4217: effectiveIso,
                ticket: ticket,
                locale: locale,
              ),
              bold: true,
            ),
            _TotalRow(
              icon: Icons.arrow_upward,
              iconColor: ticket.ticketType.iconColor,
              label: 'Monnaie rendue',
              value: _getChangeFormatted(ticket, numFormat),
            ),
          ],
        ],
        // Contact
        if (ticket.contactId != 0 ||
            ticket.contactFirstName.isNotEmpty ||
            ticket.contactLastName.isNotEmpty) ...[
          const Divider(),
          _InfoRow(
            leadingWidget: ticket.ticketType.getTicketContactIcon,
            icon: Icons.person,
            iconColor: ticket.ticketType.iconColor,
            child: Text(
              '${ticket.contactFirstName} ${ticket.contactLastName}'.trim(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (ticket.contactPhone.isNotEmpty)
            _InfoRow(icon: Icons.call, child: Text(ticket.contactPhone)),
          if (ticket.contactMail.isNotEmpty)
            _InfoRow(icon: Icons.alternate_email, child: Text(ticket.contactMail)),
        ],
        // Comment
        if (ticket.comment.isNotEmpty) ...[
          const Divider(),
          _InfoRow(icon: Icons.assignment, child: Text(ticket.comment)),
        ],
        // Cancelled
        if (!ticket.status && ticket.statusUpdateDate.isNotEmpty) ...[
          _InfoRow(
            icon: Icons.pause,
            child: Text(
              'Annulé : ${_formatDateTime(ticket.statusUpdateDate, ticket.statusUpdateDate, dateFormat, timeFormat)}',
            ),
          ),
        ],
      ],
    );
  }

  String _getBoutiqueDisplayName(dynamic cf) {
    final fromTicket = cf.boutiqueName.trim();
    if (fromTicket.isNotEmpty) return fromTicket;
    final id = cf.boutiqueId.trim();
    if (id.isEmpty) return '';
    if (boutiqueCache != null) return boutiqueCache!.getName(id);
    return id;
  }

  Widget? _getBoutiqueIcon(dynamic cf) {
    final id = cf.boutiqueId.trim();
    if (id.isEmpty || boutiqueCache == null) return null;
    if (!boutiqueCache!.hasLogo(id)) return null;
    final logo = boutiqueCache!.getLogo(id);
    if (logo == null) return null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          logo,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  String _formatDateTime(
    String dateStr,
    String timeStr,
    DateFormat dateFormat,
    DateFormat timeFormat,
  ) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return '${dateFormat.format(dt)} ${timeFormat.format(dt)}';
  }

  String _ticketTypeLabel(TicketTypePb t) {
    final name = t.name;
    if (name.isEmpty) return 'Ticket';
    return name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');
  }

  IconData _paymentIcon(dynamic pt) {
    final s = pt.toString();
    if (s == 'cash') return Icons.payments;
    if (s == 'mobileMoney') return Icons.phone_android;
    if (s == 'creditCard') return Icons.credit_card;
    if (s == 'cheque') return Icons.description;
    return Icons.payment;
  }

  String _paymentLabel(String s) {
    if (s.isEmpty) return '—';
    const map = {
      'cash': 'Espèces',
      'mobileMoney': 'Mobile Money',
      'nope': 'Crédit',
      'cheque': 'Chèque',
      'creditCard': 'Carte bancaire',
      'goods': 'Marchandises',
      'unknown': '—',
    };
    return map[s] ?? s;
  }

  String _getTotalItemsFormatted(TicketPb t, NumberFormat nf) {
    if (t.ticketType.isPrice) {
      return nf.format(t.itemsTotalComputed);
    }
    if (t.ticketType.isCost) {
      return nf.format(t.itemsTotalCostComputed);
    }
    return '0';
  }

  String _getPromoFormatted(TicketPb t, NumberFormat nf) {
    if (t.ticketType.isPrice) {
      return '- ${nf.format(t.itemsTotalComputed * t.promo / 100)}';
    }
    if (t.ticketType.isCost) {
      return '- ${nf.format(t.itemsTotalCostComputed * t.promo / 100)}';
    }
    return '0';
  }

  String _getTaxExcludedFormatted(TicketPb t, NumberFormat nf) {
    return nf.format(t.totalTaxExcludedComputed);
  }

  String _getTaxesFormatted(TicketPb t, NumberFormat nf) {
    return '+ ${nf.format(t.totalTaxesComputed)}';
  }

  String _getChangeFormatted(TicketPb t, NumberFormat nf) {
    return nf.format(t.changeComputed);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final Color? iconColor;
  final Widget? leadingWidget;

  const _InfoRow({
    required this.icon,
    required this.child,
    this.iconColor,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: leadingWidget ?? Icon(icon, color: iconColor, size: 20),
        ),
        _rowPadding,
        Flexible(
          flex: 9,
          fit: FlexFit.tight,
          child: child,
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final bool bold;

  const _TotalRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        _rowPadding,
        Flexible(
          flex: 5,
          fit: FlexFit.tight,
          child: Text(
            label,
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ),
        Flexible(
          flex: 4,
          fit: FlexFit.tight,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final TicketTypePb ticketType;
  final ItemCartPb item;
  final NumberFormat numFormat;
  final Locale locale;

  const _ItemRow({
    required this.ticketType,
    required this.item,
    required this.numFormat,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isUncountable = item.isUncountable;
    final designation = item.hasArticleRetail()
        ? item.articleRetail.designation
        : (item.hasArticleUncountable()
            ? item.articleUncountable.designation
            : (item.hasArticleBasket() ? item.articleBasket.designation : ''));
    final isPrice = ticketType.isPrice;
    final isStock = TicketTypePbLogic.stockTypes.contains(ticketType);
    final qtyStr = _formatLineQuantity(item.quantity, locale);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Icon(
            isUncountable ? Icons.insert_drive_file_rounded : Icons.widgets,
            color: isUncountable
                ? (ticketType.isPrice ? ColorsWeebi.tealSell : ColorsWeebi.redSpend)
                : ColorsWeebi.orangeArticle,
            size: 20,
          ),
        ),
        _rowPadding,
        Flexible(
          flex: 5,
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  designation,
                  style: const TextStyle(color: Colors.black),
                ),
                if (!isStock) ...[
                  const SizedBox(height: 2),
                  RichText(
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: isPrice
                              ? numFormat.format(item.articlePrice)
                              : numFormat.format(item.articleCost),
                        ),
                        TextSpan(text: ' × $qtyStr => '),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  RichText(
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: '× $qtyStr'),
                        if (ticketType == TicketTypePb.inventory &&
                            item.inventoryAbsoluteQt != 0)
                          TextSpan(
                            text:
                                ' = ${_formatLineQuantity(item.inventoryAbsoluteQt, locale)}  ',
                          ),
                        if (ticketType == TicketTypePb.inventory)
                          TextSpan(
                            text: item.quantity >= 0
                                ? '(+${_formatLineQuantity(item.quantity, locale)})'
                                : '(${_formatLineQuantity(item.quantity, locale)})',
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isStock)
          Flexible(
            flex: 4,
            fit: FlexFit.loose,
            child: Text(
              isPrice
                  ? numFormat.format(item.totalPriceComputed)
                  : numFormat.format(item.totalCostComputed),
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }
}
