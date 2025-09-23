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
      final Animal? animal = _findAnimal(value);
      if (animal != null) {
        setState(() => _found = true);
        Navigator.of(context).pop(animal);
        return;
      }
    }
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
            hintText: 'Tag ou identifiant de l’animal',
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
                  'Visez le QR code ou la puce NFC associée à l’animal pour ouvrir sa fiche instantanément.',
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
