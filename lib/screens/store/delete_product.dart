// delete_product_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteProductDialog extends StatelessWidget {
  final String productId;

  DeleteProductDialog({required this.productId});

  Future<void> _deleteProduct(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus')),
      );
      Navigator.of(context).pop(); // Tutup dialog setelah dihapus
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Hapus Produk'),
      content: Text('Anda yakin ingin menghapus produk ini?'),
      actions: [
        TextButton(
          child: Text('Batal'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Hapus'),
          onPressed: () => _deleteProduct(context),
        ),
      ],
    );
  }
}
