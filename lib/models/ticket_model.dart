class TicketModel {
  final int id;
  final String ticketNo;
  final int? orderId;
  final String category;
  final String subject;
  final String message;
  final String? attachment;
  final String status;
  final String? adminReply;
  final String createdAt;

  TicketModel({
    required this.id,
    required this.ticketNo,
    this.orderId,
    required this.category,
    required this.subject,
    required this.message,
    this.attachment,
    required this.status,
    this.adminReply,
    required this.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: int.tryParse('${json['id']}') ?? 0,
      ticketNo: json['ticket_no']?.toString() ?? '',
      orderId: json['order_id'] != null ? int.tryParse('${json['order_id']}') : null,
      category: json['category']?.toString() ?? 'Other',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      status: json['status']?.toString() ?? 'open',
      adminReply: json['admin_reply']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class TicketReplyModel {
  final String sender;
  final String message;
  final String createdAt;

  TicketReplyModel({required this.sender, required this.message, required this.createdAt});

  factory TicketReplyModel.fromJson(Map<String, dynamic> json) {
    return TicketReplyModel(
      sender: json['sender']?.toString() ?? 'admin',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}