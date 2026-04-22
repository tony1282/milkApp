import 'package:flutter/material.dart';
import 'package:milk_app/models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${payment.dateFrom.day}/${payment.dateFrom.month} – ${payment.dateTo.day}/${payment.dateTo.month}/${payment.dateTo.year}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Colors.black26),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${payment.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3D52A0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${payment.totalLiters.toStringAsFixed(1)} L  ×  \$${payment.pricePerLiter.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar corte',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('¿Estás seguro de que deseas eliminar este corte?',
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}