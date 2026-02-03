import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

class EntertainmentPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const EntertainmentPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<EntertainmentPage> createState() => _EntertainmentPageState();
}

class _EntertainmentPageState extends State<EntertainmentPage> {
  late bool _smartMobile;
  late bool _analogMobile;
  late bool _television;
  late bool _radio;
  late bool _games;
  late bool _otherEntertainment;

  late TextEditingController _smartMobileCountController;
  late TextEditingController _analogMobileCountController;
  late TextEditingController _otherEntertainmentController;

  @override
  void initState() {
    super.initState();
    _smartMobile = widget.pageData['smart_mobile'] ?? false;
    _analogMobile = widget.pageData['analog_mobile'] ?? false;
    _television = widget.pageData['television'] ?? false;
    _radio = widget.pageData['radio'] ?? false;
    _games = widget.pageData['games'] ?? false;
    _otherEntertainment = widget.pageData['other_entertainment'] != null;

    _smartMobileCountController = TextEditingController(
      text: widget.pageData['smart_mobile_count']?.toString() ?? '',
    );
    _analogMobileCountController = TextEditingController(
      text: widget.pageData['analog_mobile_count']?.toString() ?? '',
    );
    _otherEntertainmentController = TextEditingController(
      text: widget.pageData['other_entertainment'] ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant EntertainmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageData != oldWidget.pageData) {
      setState(() {
        _smartMobile = widget.pageData['smart_mobile'] ?? false;
        _analogMobile = widget.pageData['analog_mobile'] ?? false;
        _television = widget.pageData['television'] ?? false;
        _radio = widget.pageData['radio'] ?? false;
        _games = widget.pageData['games'] ?? false;
        _otherEntertainment = widget.pageData['other_entertainment'] != null;

        if (widget.pageData['smart_mobile_count']?.toString() != _smartMobileCountController.text) {
             _smartMobileCountController.text = widget.pageData['smart_mobile_count']?.toString() ?? '';
        }
        if (widget.pageData['analog_mobile_count']?.toString() != _analogMobileCountController.text) {
             _analogMobileCountController.text = widget.pageData['analog_mobile_count']?.toString() ?? '';
        }
        if (widget.pageData['other_entertainment'] != _otherEntertainmentController.text) {
             _otherEntertainmentController.text = widget.pageData['other_entertainment'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _smartMobileCountController.dispose();
    _analogMobileCountController.dispose();
    _otherEntertainmentController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'smart_mobile': _smartMobile,
      'analog_mobile': _analogMobile,
      'television': _television,
      'radio': _radio,
      'games': _games,
      'smart_mobile_count': int.tryParse(_smartMobileCountController.text),
      'analog_mobile_count': int.tryParse(_analogMobileCountController.text),
      if (_otherEntertainmentController.text.isNotEmpty)
        'other_entertainment': _otherEntertainmentController.text,
    };
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              l10n.entertainmentFacilities,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              l10n.selectEntertainmentFacilities,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Smart Mobile
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      l10n.smartMobilePhone,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.androidIosSmartphones),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.smartphone, color: Colors.blue),
                    ),
                    value: _smartMobile,
                    onChanged: (value) {
                      setState(() => _smartMobile = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_smartMobile)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _smartMobileCountController,
                        decoration: InputDecoration(
                          labelText: l10n.numberOfSmartphones,
                          hintText: l10n.enterCount,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _updateData(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Analog Mobile
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      l10n.analogMobilePhone,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.basicMobilePhones),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone_android, color: Colors.grey),
                    ),
                    value: _analogMobile,
                    onChanged: (value) {
                      setState(() => _analogMobile = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_analogMobile)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _analogMobileCountController,
                        decoration: InputDecoration(
                          labelText: l10n.numberOfAnalogPhones,
                          hintText: l10n.enterCount,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _updateData(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Television
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.television,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.tvEntertainmentNews),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tv, color: Colors.red),
                ),
                value: _television,
                onChanged: (value) {
                  setState(() => _television = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Radio
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.radio,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.radioNewsMusic),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.radio, color: Colors.orange),
                ),
                value: _radio,
                onChanged: (value) {
                  setState(() => _radio = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Games
          FadeInLeft(
            delay: const Duration(milliseconds: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: Text(
                  l10n.gamesGamingDevices,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(l10n.videoGamesBoardGames),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.games, color: Colors.purple),
                ),
                value: _games,
                onChanged: (value) {
                  setState(() => _games = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Other Entertainment
          FadeInLeft(
            delay: const Duration(milliseconds: 700),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      l10n.otherEntertainment,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(l10n.newspaperInternetEtc),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.more_horiz, color: Colors.teal),
                    ),
                    value: _otherEntertainment,
                    onChanged: (value) {
                      setState(() => _otherEntertainment = value ?? false);
                      _updateData();
                    },
                    activeColor: Colors.green,
                  ),
                  if (_otherEntertainment)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _otherEntertainmentController,
                        decoration: InputDecoration(
                          labelText: l10n.specifyOtherEntertainment,
                          hintText: l10n.entertainmentExamples,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 2,
                        onChanged: (value) => _updateData(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Information Text
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.entertainmentInfo,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Validation Message
          if (!_smartMobile && !_analogMobile && !_television && !_radio && !_games && !_otherEntertainment)
            FadeInUp(
              delay: const Duration(milliseconds: 900),
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.selectEntertainmentFacility,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
