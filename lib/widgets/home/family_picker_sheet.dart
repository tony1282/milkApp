import 'package:flutter/material.dart';
import 'package:milk_app/models/family_milk_model.dart';

class FamilyPickerSheet extends StatelessWidget {
  final List<FamilyMilkModel> families;
  final FamilyMilkModel? selectedFamily;
  final void Function(FamilyMilkModel) onSelect;

  const FamilyPickerSheet({
    super.key,
    required this.families,
    required this.selectedFamily,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text('Selecciona una familia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: families.map((family) {
                final isSelected =
                    selectedFamily?.familyId == family.familyId;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected
                      ? const Color(0xFFEEF2FF)
                      : Colors.transparent,
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? const Color(0xFF3D52A0)
                        : const Color(0xFFEEF2FF),
                    child: Text(
                      family.familyName[0].toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF3D52A0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(family.familyName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF3D52A0)
                            : Colors.black87,
                      )),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF3D52A0))
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(family);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}