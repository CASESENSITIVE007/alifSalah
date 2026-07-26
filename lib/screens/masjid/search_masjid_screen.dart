import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';
import 'masjid_detail_screen.dart';

/// Search Masjids by name or city and open their space to join.
class SearchMasjidScreen extends StatefulWidget {
  const SearchMasjidScreen({super.key});

  @override
  State<SearchMasjidScreen> createState() => _SearchMasjidScreenState();
}

class _SearchMasjidScreenState extends State<SearchMasjidScreen> {
  final _controller = TextEditingController();
  List<Masjid> _results = [];
  bool _searched = false;
  bool _busy = false;

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() => _busy = true);
    final results = await MasjidService.search(q);
    if (mounted) {
      setState(() {
        _results = results;
        _searched = true;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLang.t('find_your_masjid'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: AppLang.t('search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _busy ? null : _search),
              ),
            ),
          ),
          Expanded(
            child: _busy
                ? const Center(child: CircularProgressIndicator())
                : !_searched
                    ? Center(
                        child: Text(AppLang.t('search_prompt'),
                            style:
                                const TextStyle(color: Colors.black54)))
                    : _results.isEmpty
                        ? Center(
                            child: Text(AppLang.t('no_results'),
                                style: const TextStyle(
                                    color: Colors.black54)))
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, i) {
                              final m = _results[i];
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.lightGreen,
                                  child: Icon(Icons.mosque,
                                      color: AppTheme.deepGreen),
                                ),
                                title: Text(m.name),
                                subtitle: Text('${m.address}, ${m.city}'),
                                trailing:
                                    const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MasjidDetailScreen(
                                          masjidId: m.id)),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
