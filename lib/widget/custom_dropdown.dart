import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomDropdownInput extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownInput({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Removed the ConstrainedBox wrapper from here
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hintText),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(15.0),
      icon: const Icon(LucideIcons.chevronDown, size: 20),
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(item),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.purple, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}