import 'package:flutter/material.dart';

class SearchSuggestions extends StatelessWidget {
  final bool showSuggestions;
  final List<String> suggestions;
  final void Function(String) onSuggestionTap;

  const SearchSuggestions({
    Key? key,
    required this.showSuggestions,
    required this.suggestions,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showSuggestions || suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () => onSuggestionTap(suggestion),
          );
        },
      ),
    );
  }
}
