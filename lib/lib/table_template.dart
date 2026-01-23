import 'package:flutter/material.dart';

class TemplateScreen extends StatefulWidget {
  final String title;
  final String stepNumber;
  final String nextScreenRoute;
  final Widget contentWidget;
  final String nextScreenName;
  final IconData icon;
  final String instructions;
  final VoidCallback? onBack;
  final VoidCallback? onReset;
  
  const TemplateScreen({super.key, 
    required this.title,
    required this.stepNumber,
    required this.nextScreenRoute,
    required this.contentWidget,
    required this.nextScreenName,
    required this.icon,
    this.instructions = '',
    this.onBack,
    this.onReset,
  });

  @override
  _TemplateScreenState createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm() {
    // Navigate directly to next screen without showing dialog
    Navigator.pushNamed(context, widget.nextScreenRoute);
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.pop(context);
    }
  }

  void _resetForm() {
    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                height: 100,
                color: Colors.white,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Government of India', 
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF003366)
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Digital India', 
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16, 
                        color: Colors.orange
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(widget.icon, color: const Color(0xFF800080)),
                                  SizedBox(width: isSmallScreen ? 8 : 10),
                                  Expanded(
                                    child: Text(
                                      widget.title, 
                                      style: const TextStyle(
                                        fontSize: 20, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${widget.stepNumber}: ${widget.title}'),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Instructions
                      if (widget.instructions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.blue.shade50,
                          child: Text(widget.instructions),
                        ),
                      
                      SizedBox(height: widget.instructions.isNotEmpty ? 20 : 0),
                      
                      // Content Widget
                      widget.contentWidget,
                      
                      const SizedBox(height: 20),
                      
                      // Responsive Buttons - Only Back and Save & Continue
                      if (isSmallScreen)
                        Column(
                          children: [
                            if (widget.onBack != null)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _goBack,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade700,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.arrow_back, size: 20),
                                  label: const Text('Back to Previous'),
                                ),
                              ),
                            if (widget.onBack != null) const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF800080),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Save & Continue'),
                              ),
                            ),
                            if (widget.onReset != null) const SizedBox(height: 12),
                            if (widget.onReset != null)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _resetForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.restart_alt, size: 20),
                                  label: const Text('Reset Form'),
                                ),
                              ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            if (widget.onBack != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _goBack,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade700,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.arrow_back, size: 20),
                                  label: const Text('Back to Previous'),
                                ),
                              ),
                            if (widget.onBack != null) const SizedBox(width: 16),
                            if (widget.onReset != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _resetForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.restart_alt, size: 20),
                                  label: const Text('Reset Form'),
                                ),
                              ),
                            if (widget.onReset != null) const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF800080),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Save & Continue'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for table rows - Made responsive
class TableRowWidget extends StatelessWidget {
  final String label;
  final Widget inputWidget;
  final String? helperText;
  
  const TableRowWidget({super.key, 
    required this.label,
    required this.inputWidget,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    if (isSmallScreen) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            inputWidget,
            if (helperText != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      helperText!,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label, 
              style: const TextStyle(fontWeight: FontWeight.w500)
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: inputWidget,
          ),
          if (helperText != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: helperText!,
              child: const Icon(Icons.info_outline, size: 16, color: Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}