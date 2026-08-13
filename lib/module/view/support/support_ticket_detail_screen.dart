import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/controller/support_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportTicketDetailScreen extends StatefulWidget {
  final int ticketId;
  const SupportTicketDetailScreen({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<SupportTicketDetailScreen> createState() => _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  final _replyCtrl = TextEditingController();
  late final SupportDetailController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(SupportDetailController(widget.ticketId), tag: 'ticket_${widget.ticketId}');
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    _replyCtrl.clear();
    FocusScope.of(context).unfocus();
    await ctrl.sendReply(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Support Request')),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticket = ctrl.ticket.value;
        if (ticket == null) {
          return const Center(child: Text('Unable to load this ticket'));
        }

        final statusColor = AppTheme.statusColor(ticket.status);

        return RefreshIndicator(
          onRefresh: ctrl.fetchDetail,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Ticket header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ticket.ticketNo,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            ticket.status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${ticket.category} · Raised on ${ticket.createdAt}',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Conversation thread — original message first, then replies in order
              _bubble(
                text: ticket.message,
                time: ticket.createdAt,
                isMe: true,
              ),
              if (ticket.attachment != null && ticket.attachment!.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12, right: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ticket.attachment!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ...ctrl.replies.map((r) => _bubble(
                text: r.message,
                time: r.createdAt,
                isMe: r.sender == 'customer',
                senderLabel: r.sender == 'admin' ? 'Support Team' : null,
              )),

              if (ticket.status == 'resolved' || ticket.status == 'closed') ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    ticket.status == 'resolved' ? 'This request has been resolved' : 'This request is closed',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Obx(() {
          final ticket = ctrl.ticket.value;
          // No point showing a composer while it's still loading, or if we
          // couldn't load the ticket at all.
          if (ctrl.isLoading.value || ticket == null) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.bg,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => Material(
                  color: AppTheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: ctrl.isSending.value ? null : _send,
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: ctrl.isSending.value
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                      )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                )),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _bubble({required String text, required String time, required bool isMe, String? senderLabel}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe ? null : Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (senderLabel != null) ...[
              Text(senderLabel,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : AppTheme.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 3),
            ],
            Text(text, style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 13.5, height: 1.4)),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : AppTheme.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}