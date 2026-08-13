class OrderModel {
  final int id;
  final String company;
  final String? orderNo;
  final String? orderRef;
  final String? orderDate;
  final double gTotal;
  final double grandTotal;
  final String billingStatus;
  final String? orderPdfLink;
  final String? deliverySlipLink;
  final String? TallyBillLink;
  final String? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.company,
    this.orderNo,
    this.orderRef,
    this.orderDate,
    required this.gTotal,
    required this.grandTotal,
    required this.billingStatus,
    this.orderPdfLink,
    this.deliverySlipLink,
    this.TallyBillLink,
    this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    List<OrderItemModel> parseItems(dynamic raw) =>
        (raw as List? ?? []).map((e) => OrderItemModel.fromJson(e)).toList();
    return OrderModel(
      id: int.tryParse('${json['id']}') ?? 0,
      company: json['company']?.toString() ?? '1',
      orderNo: json['order_no']?.toString(),
      orderRef: json['order_ref']?.toString(),
      orderDate: json['order_date']?.toString(),
      gTotal: double.tryParse('${json['g_total'] ?? 0}') ?? 0,
      grandTotal: double.tryParse('${json['grand_total'] ?? 0}') ?? 0,
      billingStatus: json['billing_status']?.toString() ?? 'pending',
      orderPdfLink: json['order_pdf_link']?.toString(),
      deliverySlipLink: json['delivery_slip_link']?.toString(),
      TallyBillLink: json['tally_bill_link']?.toString(),
      createdAt: json['created_at']?.toString(),
      items:         parseItems(data['items']),
    );
  }
}

class OrderItemModel {
  final int id;
  final int? productId;
  final String? productName;
  final String? productCode;
  final String? slNo;
  final int qty;
  final double price;
  final double total;

  OrderItemModel({
    required this.id,
    this.productId,
    this.productName,
    this.productCode,
    this.slNo,
    required this.qty,
    required this.price,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) =>
      OrderItemModel(
        id: j['order_item_id'] ?? j['id'] ?? 0,
        productId: j['product_id'],
        productName: j['product_name'],
        productCode: j['product_code'],
        slNo: j['sl_no'],
        qty: j['qty'] ?? 1,
        price: (j['price'] ?? 0).toDouble(),
        total: (j['total'] ?? j['price'] ?? 0).toDouble(),
      );
}
class OrderDetailModel {
  final OrderModel order;
  final String? billingAdd;
  final String? shippingAdd;
  final String? installationAdd;
  final List<OrderItemModel> items;
  final List<ExchangeItemDetail> exchangeItems;
  final List<PaymentDetail> payments;

  OrderDetailModel({
    required this.order,
    this.billingAdd,
    this.shippingAdd,
    this.installationAdd,
    required this.items,
    required this.exchangeItems,
    required this.payments,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    List<OrderItemModel> parseItems(dynamic raw) =>
        (raw as List? ?? []).map((e) => OrderItemModel.fromJson(e)).toList();

    List<ExchangeItemDetail> parseEx(dynamic raw) =>
        (raw as List? ?? []).map((e) => ExchangeItemDetail.fromJson(e)).toList();

    List<PaymentDetail> parsePay(dynamic raw) =>
        (raw as List? ?? []).map((e) => PaymentDetail.fromJson(e)).toList();
    return OrderDetailModel(
      order: OrderModel.fromJson(json),
      billingAdd: json['billing_add']?.toString(),
      shippingAdd: json['shipping_add']?.toString(),
      installationAdd: json['installation_add']?.toString(),
      items:         parseItems(data['items']),
      exchangeItems: parseEx(data['exchange_items']),
      payments:      parsePay(data['payments']),

    );
  }
}

class ExchangeItemDetail {
  final int id;
  final int? exProductId;
  final String? productName;
  final int qty;
  final double price;
  final double total;

  ExchangeItemDetail({
    required this.id,
    this.exProductId,
    this.productName,
    required this.qty,
    required this.price,
    required this.total,
  });

  factory ExchangeItemDetail.fromJson(Map<String, dynamic> j) =>
      ExchangeItemDetail(
        id: j['id'] ?? 0,
        exProductId: j['ex_product_id'],
        productName: j['name'],
        qty: j['qty'] ?? 1,
        price: (j['price'] ?? 0).toDouble(),
        total: (j['total'] ?? 0).toDouble(),
      );
}

class PaymentDetail {
  final int id;
  final String? modeName;
  final double amount;
  final String? details;

  PaymentDetail({
    required this.id,
    this.modeName,
    required this.amount,
    this.details,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> j) => PaymentDetail(
    id: j['id'] ?? 0,
    modeName: j['mode_name'] ?? j['payment_mode'],
    amount: (j['amount'] ?? 0).toDouble(),
    details: j['payment_details'] ?? j['details'],
  );
}