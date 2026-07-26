import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/tasbeehs.dart';
import '../../l10n/app_lang.dart';
import '../../theme.dart';

/// Interactive digital Tasbih: pick a dhikr, tap anywhere on the big
/// counter to count with haptic feedback. Counts and completed rounds
/// are saved on the device per tasbeeh.
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  SharedPreferences? _prefs;
  Tasbeeh _selected = kTasbeehs.first;
  int _count = 0;
  int _rounds = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedId = prefs.getString('tasbih_sel') ?? kTasbeehs.first.id;
    final selected = kTasbeehs.firstWhere((t) => t.id == selectedId,
        orElse: () => kTasbeehs.first);
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _selected = selected;
        _count = prefs.getInt('tasbih_c_${selected.id}') ?? 0;
        _rounds = prefs.getInt('tasbih_r_${selected.id}') ?? 0;
      });
    }
  }

  void _persist() {
    _prefs?.setString('tasbih_sel', _selected.id);
    _prefs?.setInt('tasbih_c_${_selected.id}', _count);
    _prefs?.setInt('tasbih_r_${_selected.id}', _rounds);
  }

  void _tap() {
    setState(() {
      _count++;
      if (_count >= _selected.target) {
        _count = 0;
        _rounds++;
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    });
    _persist();
  }

  void _reset() {
    setState(() {
      _count = 0;
      _rounds = 0;
    });
    _persist();
  }

  void _select(Tasbeeh t) {
    setState(() {
      _selected = t;
      _count = _prefs?.getInt('tasbih_c_${t.id}') ?? 0;
      _rounds = _prefs?.getInt('tasbih_r_${t.id}') ?? 0;
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final translation = AppLang.isUrdu ? _selected.urdu : _selected.english;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLang.t('tasbih')),
        actions: [
          IconButton(
            tooltip: AppLang.t('reset'),
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // Dhikr selector + text card.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _showPicker,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _selected.arabic,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  height: 1.6,
                                  color: AppTheme.deepGreen),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.expand_more,
                              color: Colors.black38),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selected.transliteration,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Big tap-to-count area.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _tap,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: _selected.target == 0
                                ? 0
                                : _count / _selected.target,
                            strokeWidth: 10,
                            backgroundColor: AppTheme.lightGreen,
                            color: AppTheme.deepGreen,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$_count',
                              style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.deepGreen),
                            ),
                            Text(
                              '/ ${_selected.target}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${AppLang.t('rounds')}: $_rounds',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepGreen),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLang.t('tap_to_count'),
                      style: const TextStyle(
                          fontSize: 12.5, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text(AppLang.t('choose_tasbih'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final t in kTasbeehs)
              Card(
                color: t.id == _selected.id ? AppTheme.lightGreen : null,
                child: ListTile(
                  onTap: () {
                    _select(t);
                    Navigator.pop(sheetContext);
                  },
                  title: Text(
                    t.arabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                        color: AppTheme.deepGreen),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.transliteration,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic)),
                      Text(AppLang.isUrdu ? t.urdu : t.english,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('×${t.target}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.gold)),
                      if (t.id == _selected.id)
                        const Icon(Icons.check,
                            color: AppTheme.deepGreen, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
