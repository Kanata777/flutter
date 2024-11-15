class PaymentModel {
  static List<Payment> _payments = [];

  static Future<void> addPayment(String productName, double totalPrice, String date, bool isSuccess) async {
    // Simulasi penyimpanan ke database atau API
    Payment newPayment = Payment(
      productName: productName,
      totalPrice: totalPrice,
      date: date,
      isSuccess: isSuccess,
    );
    _payments.add(newPayment);
    
    // Simpan ke database jika diperlukan
    // Contoh: await database.save(newPayment);
  }

  static List<Payment> getPayments() {
    return _payments;
  }
}

class Payment {
  final String productName;
  final double totalPrice;
  final String date;
  final bool isSuccess;

  Payment({
    required this.productName,
    required this.totalPrice,
    required this.date,
    required this.isSuccess,
  });
}
