import 'package:flutter/material.dart';

class AutocompleteDropdown extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> options;
  final TextEditingController controller;
  final String? initialValue;
  final Function(String)? onChanged;
  final bool enabled;

  const AutocompleteDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.controller,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AutocompleteDropdown> createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  late TextEditingController _localController;
  List<String> _filteredOptions = [];
  bool _showDropdown = false;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _localController = widget.controller;
    _localController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.initialValue != null) {
      _localController.text = widget.initialValue!;
      // Initialize filtered options without setState since we're in initState
      final text = widget.initialValue!.toLowerCase();
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(text))
          .toList();
    } else {
      _filteredOptions = widget.options;
    }
  }

  @override
  void dispose() {
    _localController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _localController.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(text))
          .toList();
      _showDropdown = text.isNotEmpty && _filteredOptions.isNotEmpty;
    });
    widget.onChanged?.call(_localController.text);
  }

  void _onFocusChanged() {
    setState(() {
      _showDropdown = _focusNode.hasFocus && _localController.text.isNotEmpty && _filteredOptions.isNotEmpty;
    });
  }

  void _selectOption(String option) {
    _localController.text = option;
    setState(() {
      _showDropdown = false;
    });
    _focusNode.unfocus();
    widget.onChanged?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _localController,
            focusNode: _focusNode,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_showDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                onPressed: () {
                  setState(() {
                    if (_showDropdown) {
                      _showDropdown = false;
                      _focusNode.unfocus();
                    } else {
                      _filteredOptions = widget.options;
                      _showDropdown = true;
                      _focusNode.requestFocus();
                    }
                  });
                },
              ),
            ),
          ),
          if (_showDropdown)
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, 60), // Adjust based on TextField height
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    minWidth: MediaQuery.of(context).size.width - 32, // Match parent width
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];
                      return ListTile(
                        title: Text(option),
                        onTap: () => _selectOption(option),
                        dense: true,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}