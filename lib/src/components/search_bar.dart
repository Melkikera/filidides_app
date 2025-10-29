import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;

  const SearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Rechercher un lieu...',
          suffixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
