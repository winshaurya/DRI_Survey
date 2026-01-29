import 'package:flutter/material.dart';

class FormTemplateScreen extends StatefulWidget {
  final String title;
  final String stepNumber;
  final String nextScreenRoute;
  final Widget contentWidget;
  final String nextScreenName;
  final IconData icon;
  final String instructions;
  final VoidCallback? onSubmit;
  final VoidCallback? onBack;
  final bool showHeader;
  final Color? primaryColor;
  final Color? backgroundColor;
  final VoidCallback onReset;
  final Widget? drawer;
  
  const FormTemplateScreen({super.key, 
    required this.title,
    required this.stepNumber,
    required this.nextScreenRoute,
    required this.contentWidget,
    required this.nextScreenName,
    required this.icon,
    this.instructions = '',
    this.onSubmit,
    this.onBack,
    this.showHeader = true,
    this.primaryColor,
    this.backgroundColor,
    required this.onReset,
    this.drawer,
  });

  @override
  _FormTemplateScreenState createState() => _FormTemplateScreenState();
}

class _FormTemplateScreenState extends State<FormTemplateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Color get _primaryColor => widget.primaryColor ?? Color(0xFF800080);
  Color get _backgroundColor => widget.backgroundColor ?? Color(0xFFF5F5F5);

  void _submitForm() {
    // Always submit, don't validate (fields can be empty)
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    } else {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: _primaryColor),
            SizedBox(width: 10),
            Text('Data Saved'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.title} data saved.'),
            SizedBox(height: 10),
            Text('Continue to ${widget.nextScreenName}?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Edit', style: TextStyle(color: _primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, widget.nextScreenRoute);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data saved!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    // If onBack callback is provided, use it
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      // Otherwise, just navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: widget.drawer,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: widget.drawer != null
            ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: _primaryColor),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                ),
              )
            : IconButton(
                icon: Icon(Icons.arrow_back, color: _primaryColor),
                onPressed: _goBack,
                tooltip: 'Go back',
              ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Card
                    _buildTitleCard(),
                    
                    SizedBox(height: 25),
                    
                    // Instructions
                    if (widget.instructions.isNotEmpty)
                      _buildInstructionsCard(),
                    
                    SizedBox(height: widget.instructions.isNotEmpty ? 20 : 0),
                    
                    // Content Widget
                    widget.contentWidget,
                    
                    SizedBox(height: 20),
                    
                    // Buttons
                    _buildActionButtons(),
                    
                    SizedBox(height: 40), // Extra padding at bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header removed per requirement

  Widget _buildTitleCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: _primaryColor, size: 32),
                SizedBox(width: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '${widget.stepNumber}: ${widget.title}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 5),
            Container(
              height: 4,
              width: 100,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 3,
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade800),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.instructions,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Back to Previous Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _goBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(Icons.arrow_back, size: 20),
            label: Text('Back to Previous'),
          ),
        ),
        SizedBox(width: 16),
        
        // Save & Continue Button
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Save & Continue'),
          ),
        ),
      ],
    );
  }
}

// ==================== HELPER WIDGETS ====================

// Question with Background
class QuestionCard extends StatelessWidget {
  final String question;
  final Widget child;
  final String? description;
  final Color? accentColor;

  const QuestionCard({super.key, 
    required this.question,
    required this.child,
    this.description,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color _accentColorValue = accentColor ?? Color(0xFF800080);
    
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _accentColorValue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColorValue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentColorValue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 15),
          // Child Widget
          child,
        ],
      ),
    );
  }
}

// Text Input with Icon
class TextInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool isRequired;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? helperText;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;

  const TextInput({super.key, 
    required this.label,
    required this.controller,
    this.hintText = '',
    this.keyboardType = TextInputType.text,
    this.isRequired = false, // CHANGED: Now optional by default
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF800080), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Color(0xFF800080)) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade400) : null,
        helperText: helperText,
      ),
      validator: validator, // CHANGED: No default validator
      onChanged: onChanged,
      onSaved: onSaved,
      style: TextStyle(color: Colors.grey.shade800),
    );
  }
}

// Number Input (for numeric fields)
class NumberInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isRequired;
  final IconData? prefixIcon;
  final String? helperText;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;

  const NumberInput({super.key, 
    required this.label,
    required this.controller,
    this.hintText = '',
    this.isRequired = false, // CHANGED: Now optional by default
    this.prefixIcon,
    this.helperText,
    this.validator,
    this.onChanged,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextInput(
      label: label,
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.number,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      helperText: helperText,
      validator: validator, // CHANGED: No default validator
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}

// Dropdown Input
class DropdownInput extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final bool isRequired;
  final IconData? prefixIcon;
  final String? helperText;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final bool enabled;

  const DropdownInput({super.key, 
    required this.label,
    required this.value,
    required this.items,
    this.isRequired = false, // CHANGED: Now optional by default
    this.prefixIcon,
    this.helperText,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  _DropdownInputState createState() => _DropdownInputState();
}

class _DropdownInputState extends State<DropdownInput> {
  String? _selectedValue;

  @override
  void initState() {
    _selectedValue = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(DropdownInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value != null && widget.items.contains(widget.value)) {
        setState(() {
          _selectedValue = widget.value;
        });
      } else if (widget.value == null || widget.value!.isEmpty) {
        setState(() {
          _selectedValue = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.enabled ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedValue?.isEmpty ?? true ? null : _selectedValue,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: widget.enabled ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: widget.prefixIcon != null 
              ? Icon(widget.prefixIcon, color: Color(0xFF800080))
              : null,
          helperText: widget.helperText,
        ),
        items: widget.items.toSet().toList().map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: widget.enabled ? Colors.grey.shade800 : Colors.grey.shade400,
              ),
            ),
          );
        }).toList(),
        onChanged: widget.enabled ? (value) {
          setState(() => _selectedValue = value);
          if (widget.onChanged != null) widget.onChanged!(value);
        } : null,
        validator: widget.validator, // CHANGED: No default validator
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF800080)),
        style: TextStyle(color: Colors.grey.shade800),
        dropdownColor: Colors.white,
      ),
    );
  }
}

// Simple Table for multiple inputs
class SimpleTable extends StatelessWidget {
  final List<String> headers;
  final List<Widget> rows;

  const SimpleTable({super.key, 
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF800080),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: headers.map((header) => Expanded(
                  child: Text(
                    header,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                )).toList(),
              ),
            ),
            
            SizedBox(height: 10),
            
            // Table Rows
            ...rows,
          ],
        ),
      ),
    );
  }
}

// Table Row Widget
class TableRow extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const TableRow({super.key, 
    required this.children,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: padding ?? EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(children: children),
    );
  }
}

// Radio Option Group
class RadioOptionGroup extends StatefulWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;
  final String? description;
  final Color? accentColor;

  const RadioOptionGroup({super.key, 
    required this.label,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.description,
    this.accentColor,
  });

  @override
  _RadioOptionGroupState createState() => _RadioOptionGroupState();
}

class _RadioOptionGroupState extends State<RadioOptionGroup> {
  String? _selectedValue;

  @override
  void initState() {
    _selectedValue = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: widget.label,
      description: widget.description,
      accentColor: widget.accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.options.map((option) => RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _selectedValue,
          onChanged: (value) {
            setState(() => _selectedValue = value);
            widget.onChanged(value);
          },
          activeColor: widget.accentColor ?? Color(0xFF800080),
        )).toList(),
      ),
    );
  }
}

// Warning Alert Widget
class WarningAlert extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;

  const WarningAlert({super.key, 
    required this.message,
    this.icon = Icons.info,
    this.color = Colors.orange,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Success Alert (Green)
class SuccessAlert extends StatelessWidget {
  final String message;

  const SuccessAlert({super.key, 
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return WarningAlert(
      message: message,
      icon: Icons.check_circle,
      color: Colors.green,
      backgroundColor: Colors.green.shade50,
    );
  }
}

// Info Alert (Blue)
class InfoAlert extends StatelessWidget {
  final String message;

  const InfoAlert({super.key, 
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return WarningAlert(
      message: message,
      icon: Icons.info_outline,
      color: Colors.blue,
      backgroundColor: Colors.blue.shade50,
    );
  }
}

// Checkbox List (for multiple selections)
class CheckboxList extends StatefulWidget {
  final String label;
  final Map<String, bool> items;
  final ValueChanged<Map<String, bool>> onChanged;
  final String? description;
  final Color? accentColor;

  const CheckboxList({super.key, 
    required this.label,
    required this.items,
    required this.onChanged,
    this.description,
    this.accentColor,
  });

  @override
  _CheckboxListState createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  Map<String, bool> _items = {};

  @override
  void initState() {
    _items = Map.from(widget.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: widget.label,
      description: widget.description,
      accentColor: widget.accentColor,
      child: Column(
        children: _items.entries.map((entry) => CheckboxListTile(
          title: Text(entry.key),
          value: entry.value,
          onChanged: (value) {
            setState(() {
              _items[entry.key] = value ?? false;
            });
            widget.onChanged(Map.from(_items));
          },
          activeColor: widget.accentColor ?? Color(0xFF800080),
          controlAffinity: ListTileControlAffinity.leading,
        )).toList(),
      ),
    );
  }
}