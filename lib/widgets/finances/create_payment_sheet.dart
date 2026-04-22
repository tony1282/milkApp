import 'package:flutter/material.dart';

class CreatePaymentSheet extends StatefulWidget {
  final DateTime from;
  final DateTime to;
  final double liters;
  final Future<void> Function(double pricePerLiter) onSave;

  const CreatePaymentSheet({
    super.key,
    required this.from,
    required this.to,
    required this.liters,
    required this.onSave,
  });

  @override
  State<CreatePaymentSheet> createState() => _CreatePaymentSheetState();
}

class _CreatePaymentSheetState extends State<CreatePaymentSheet> {
  final TextEditingController _priceController = TextEditingController();
  bool _saving = false;
  String? _errorText;

  double get _total =>
      widget.liters * (double.tryParse(_priceController.text) ?? 0);

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final price = double.tryParse(_priceController.text);

    // ── Validaciones ──
    if (_priceController.text.trim().isEmpty) {
      setState(() => _errorText = 'Ingresa el precio por litro');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _errorText = 'El precio debe ser un número mayor a 0');
      return;
    }
    if (widget.liters <= 0) {
      setState(() =>
          _errorText = 'No hay litros registrados en el periodo seleccionado');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await widget.onSave(price);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = 'Error al guardar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // ── Título ──
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: Color(0xFF3D52A0), size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nuevo corte',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E))),
                  Text(
                    '${widget.from.day}/${widget.from.month}/${widget.from.year} — ${widget.to.day}/${widget.to.month}/${widget.to.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Litros del periodo ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.liters > 0
                  ? const Color(0xFFEEF2FF)
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.liters > 0
                      ? 'Total litros en el periodo'
                      : 'Sin registros en este periodo',
                  style: TextStyle(
                      fontSize: 13,
                      color: widget.liters > 0
                          ? Colors.black54
                          : Colors.orange.shade700),
                ),
                Text(
                  '${widget.liters.toStringAsFixed(1)} L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: widget.liters > 0
                        ? const Color(0xFF3D52A0)
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Campo precio ──
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _errorText != null
                    ? Colors.red.shade300
                    : const Color(0xFFDDE1FF),
              ),
            ),
            child: TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              onChanged: (_) => setState(() => _errorText = null),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D52A0),
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Precio por litro',
                labelStyle: TextStyle(fontSize: 13, color: Colors.black45),
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7091E6),
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // ── Error ──
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _errorText!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade400),
              ),
            ),

          const SizedBox(height: 12),

          // ── Total calculado en tiempo real ──
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF3D52A0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a cobrar',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Botón guardar ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving || widget.liters <= 0 ? null : _handleSave,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_saving ? 'Guardando...' : 'Guardar corte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D52A0),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}