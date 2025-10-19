import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../data/models/animal.dart';

class ScanAnimalScreen extends StatefulWidget {
  const ScanAnimalScreen({
    required this.animals,
    super.key,
  });

  final List<Animal> animals;

  @override
  State<ScanAnimalScreen> createState() => _ScanAnimalScreenState();
}

class _ScanAnimalScreenState extends State<ScanAnimalScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _found = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_found) {
      return;
    }
    final Iterable<Barcode> barcodes = capture.barcodes;
    for (final Barcode code in barcodes) {
      final String? value = code.rawValue?.trim();
      if (value == null || value.isEmpty) {
        continue;
      }
      final Animal? animal = _resolveAnimal(value);
      if (animal != null) {
        setState(() => _found = true);
        Navigator.of(context).pop(animal);
        return;
      }
    }
  }

  Animal? _resolveAnimal(String raw) {
    final Animal? parsed = _tryParsePayload(raw);
    return parsed ?? _findAnimal(raw);
  }

  Animal? _tryParsePayload(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final String? type = decoded['type'] as String?;
        if (type == 'khodan.animal') {
          final String? id = decoded['animal_id'] as String? ?? decoded['id'] as String?;
          final String? tag = decoded['tag'] as String?;
          if (id != null) {
            final Animal? byId = _findAnimal(id);
            if (byId != null) {
              return byId;
            }
          }
          if (tag != null) {
            final Animal? byTag = _findAnimal(tag);
            if (byTag != null) {
              return byTag;
            }
          }
        }
      }
    } catch (_) {
      // Ignore malformed payloads
    }
    return null;
  }

  Animal? _findAnimal(String tag) {
    final String normalized = tag.toLowerCase();
    for (final Animal animal in widget.animals) {
      if (animal.tagId.toLowerCase() == normalized ||
          animal.id.toLowerCase() == normalized) {
        return animal;
      }
    }
    return null;
  }

  Future<void> _enterManually() async {
    final TextEditingController controller = TextEditingController();
    final String? tag = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Entrer un identifiant'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Tag, identifiant ou payload QR',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (tag != null && tag.isNotEmpty) {
      final Animal? animal = _findAnimal(tag);
      if (animal != null) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(animal);
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun animal trouvé pour $tag.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un animal'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                const Text(
                  'Visez le QR code généré dans la fiche animal ou la puce NFC pour ouvrir sa fiche instantanément.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _enterManually,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Saisie manuelle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
