import 'package:flutter/material.dart';

class MilkBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isNew;
  final double? initialValue;
  final Future<void> Function(double liters) onSave;
  final Future<void> Function()? onDelete;

  const MilkBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isNew,
    required this.onSave,
    this.initialValue,
    this.onDelete,
  });

  @override
  State<MilkBottomSheet> createState() => _MilkBottomSheetState();
}

class _MilkBottomSheetState extends State<MilkBottomSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue != null ? '${widget.initialValue}' : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final liters = double.tryParse(_controller.text);

    if (_controller.text.trim().isEmpty) {
      setState(() => _errorText = 'Ingresa la cantidad de litros');
      return;
    }
    if (liters == null || liters <= 0) {
      setState(() => _errorText = 'Ingresa un número mayor a 0');
      return;
    }
    if (liters > 9999) {
      setState(() => _errorText = 'Valor demasiado alto');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await widget.onSave(liters);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = 'Error: $e';
      });
    }
  }

  Future<void> _handleDelete() async {
    if (widget.onDelete == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar registro',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('¿Estás seguro de eliminar este registro?',
            style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _saving = true);
    try {
      await widget.onDelete!();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = 'Error al eliminar: $e';
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
          // Handle
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

          // Título
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.water_drop_rounded,
                    color: Color(0xFF3D52A0), size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E))),
                  Text(widget.subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black45)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Campo litros
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
              controller: _controller,
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
                labelText: 'Litros de leche',
                labelStyle: TextStyle(fontSize: 13, color: Colors.black45),
                suffixText: 'L',
                suffixStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7091E6)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(_errorText!,
                  style: TextStyle(
                      fontSize: 12, color: Colors.red.shade400)),
            ),

          const SizedBox(height: 20),

          // Botones
          Row(
            children: [
              if (widget.onDelete != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _handleDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(color: Colors.red[200]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _handleSave,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_saving
                      ? 'Guardando...'
                      : widget.isNew
                          ? 'Guardar'
                          : 'Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D52A0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}