import 'package:flutter/material.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBox(),
          SizedBox(height: 16),
          Text('Sin familias registradas',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Crea una familia desde el menú lateral',
              style: TextStyle(color: Colors.black45, fontSize: 13)),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.group_add_rounded,
          color: Color(0xFF3D52A0), size: 40),
    );
  }
}