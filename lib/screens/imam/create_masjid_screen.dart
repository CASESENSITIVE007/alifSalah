import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/models.dart';
import '../../services/masjid_service.dart';
import '../../theme.dart';

/// Imam creates the Masjid's Community Space. Location is captured from
/// the device GPS (stand inside the Masjid) so the Nearby feature works.
class CreateMasjidScreen extends StatefulWidget {
  final AppUser profile;
  const CreateMasjidScreen({super.key, required this.profile});

  @override
  State<CreateMasjidScreen> createState() => _CreateMasjidScreenState();
}

class _CreateMasjidScreenState extends State<CreateMasjidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  Position? _position;
  bool _busy = false;
  String? _error;

  Future<void> _captureLocation() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required.');
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_position == null) {
      setState(() =>
          _error = 'Capture the Masjid\'s location before creating the space.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await MasjidService.createMasjid(
        name: _name.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        lat: _position!.latitude,
        lng: _position!.longitude,
        imamName: widget.profile.name,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Could not create the Masjid space. Please try again.';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Masjid space')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Masjid name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Address (street / colony)'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'City'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(
                  _position == null ? Icons.location_off : Icons.location_on,
                  color: _position == null ? Colors.black38 : AppTheme.deepGreen,
                ),
                title: Text(_position == null
                    ? 'Masjid location not captured'
                    : 'Location captured ✓'),
                subtitle: Text(_position == null
                    ? 'Stand inside the Masjid and tap Capture. This powers the "Nearby Masjids" feature.'
                    : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'),
                trailing: TextButton(
                  onPressed: _busy ? null : _captureLocation,
                  child: const Text('Capture'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
              ),
            FilledButton(
              onPressed: _busy ? null : _create,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Community Space'),
            ),
            const SizedBox(height: 8),
            const Text(
              'New Masjid spaces are marked "pending verification" to prevent fraudulent listings. Verification is completed by the Alif-Salah team.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
