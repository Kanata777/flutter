// payment_model.dart
class PaymentModel {
  static final List<Map<String, dynamic>> payments = [];

  static void addPayment(String productName, double price, String date, bool isPaid) {
    payments.add({
      'productName': productName,
      'price': price,
      'date': date,
      'isPaid': isPaid,
    });
  }
}
