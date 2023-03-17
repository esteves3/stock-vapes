import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String? userName;
  int? quantity;
  String? notes;
  int? vapeId;
  double? unitPrice;
  String? vapeImage;
  Timestamp? dtReservation;
  String? vapeFlavor;
  int? userId;
  Timestamp? dtCri;
  int? vapeNewStock;
  double get total {
    return quantity! * unitPrice!;
  }

  Sale(
      {this.userName,
      this.quantity,
      this.notes,
      this.vapeId,
      this.unitPrice,
      this.vapeImage,
      this.dtReservation,
      this.vapeFlavor,
      this.userId,
      this.dtCri,
      this.vapeNewStock});

  Sale.fromJson(Map<String, dynamic> json) {
    userName = json['user_name'];
    quantity = json['quantity'];
    notes = json['notes'];
    vapeId = json['vape_id'];
    unitPrice = json['unit_price'];
    vapeImage = json['vape_image'];
    dtReservation = json['dt_reservation'];
    vapeFlavor = json['vape_flavor'];
    userId = json['user_id'];
    dtCri = json['dt_cri'];
    vapeNewStock = json['vape_new_stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_name'] = userName;
    data['quantity'] = quantity;
    data['notes'] = notes;
    data['vape_id'] = vapeId;
    data['unit_price'] = unitPrice;
    data['vape_image'] = vapeImage;
    data['dt_reservation'] = dtReservation;
    data['vape_flavor'] = vapeFlavor;
    data['user_id'] = userId;
    data['dt_cri'] = dtCri;
    data['vape_new_stock'] = vapeNewStock;
    return data;
  }
}
