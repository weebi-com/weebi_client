import 'package:design_weebi/design_weebi.dart';
import 'package:flutter/material.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:web_admin/core/money/money_formatting.dart';
import 'package:web_admin/providers/tickets_boutique_cache.dart';
import 'package:web_admin/views/screens/tickets/ticket_type_ui_ext.dart';

/// Short abridged display of a ticket for list overview.
/// Uses TicketType extension from design_weebi for icons/colors.
class TicketGlimpseWidget extends StatelessWidget {
  final TicketPb ticket;
  final VoidCallback onTap;
  final bool isSoftDeleted;
  final TicketsBoutiqueCache? boutiqueCache;

  const TicketGlimpseWidget({
    super.key,
    required this.ticket,
    required this.onTap,
    this.isSoftDeleted = false,
    this.boutiqueCache,
  });

  String _getTicketSummary(BuildContext context) {
    if (isSoftDeleted) return 'Supprimé';
    if (!ticket.status) return 'Annulé';

    final typeLabel = _formatTicketType(ticket.ticketType);
    final type = ticket.ticketType;
    final locale = Localizations.localeOf(context);
    final iso = boutiqueCache
        ?.getBillingCurrency(ticket.counterfoil.boutiqueId);

    String amount;
    if (ticket.received > 0) {
      amount = MoneyFormatting.formatTicketAmountLine(
        localAmount: ticket.received,
        boutiqueIso4217: iso,
        ticket: ticket,
        locale: locale,
      );
    } else if (type.isFinancial &&
        ticket.items.isNotEmpty) {
      try {
        final total = ticket.totalComputed;
        amount = MoneyFormatting.formatTicketAmountLine(
          localAmount: total,
          boutiqueIso4217: iso,
          ticket: ticket,
          locale: locale,
        );
      } catch (_) {
        amount = ticket.items.isEmpty ? '—' : '${ticket.items.length} article(s)';
      }
    } else {
      amount = ticket.items.isEmpty ? '—' : '${ticket.items.length} article(s)';
    }

    return '$typeLabel : $amount';
  }

  String _formatTicketType(TicketTypePb type) {
    final name = type.name;
    if (name.isEmpty) return 'Ticket';
    return name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');
  }

  String _getContactName() {
    final first = ticket.contactFirstName.trim();
    final last = ticket.contactLastName.trim();
    if (first.isEmpty && last.isEmpty) return '';
    return '$first $last'.trim();
  }

  String _getDateAndIdLine() {
    final date = ticket.date;
    final id = ticket.nonUniqueId;
    if (id == 0) return date;
    return '$date · n°$id';
  }

  String _getBoutiqueName() {
    final fromTicket = ticket.counterfoil.boutiqueName.trim();
    if (fromTicket.isNotEmpty) return fromTicket;
    final id = ticket.counterfoil.boutiqueId.trim();
    if (id.isEmpty) return '';
    if (boutiqueCache != null) return boutiqueCache!.getName(id);
    return id;
  }

  Widget? _getBoutiqueIcon() {
    final id = ticket.counterfoil.boutiqueId.trim();
    if (id.isEmpty || boutiqueCache == null) return null;
    if (!boutiqueCache!.hasLogo(id)) return null;
    final logo = boutiqueCache!.getLogo(id);
    if (logo == null) return null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.memory(
        logo,
        width: 20,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.storefront, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isActive = ticket.status && !isSoftDeleted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 8),
                    child: Icon(
                      ticket.ticketType.iconData,
                      color: isActive
                          ? ticket.ticketType.iconColor
                          : ColorsWeebi.greyTicket,
                    ),
                  ),
                  if (!isActive)
                    Text(
                      isSoftDeleted ? 'Supprimé' : 'Annulé',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: isSoftDeleted ? Colors.red[700] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTicketSummary(context),
                    style: themeData.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_getBoutiqueName().isNotEmpty)
                    Row(
                      children: [
                        if (_getBoutiqueIcon() != null) ...[
                          _getBoutiqueIcon()!,
                          const SizedBox(width: 6),
                        ],
                        Text(
                          _getBoutiqueName(),
                          style: themeData.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: themeData.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  if (!TicketTypePbLogic.stockTypes.contains(ticket.ticketType))
                    if (_getContactName().isNotEmpty)
                      Text(
                        _getContactName(),
                        style: themeData.textTheme.bodySmall,
                      ),
                  Text(
                    _getDateAndIdLine(),
                    style: themeData.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
