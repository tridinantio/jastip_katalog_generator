import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

class ProductImageCropPage extends StatefulWidget {
  const ProductImageCropPage({required this.imageBytes, super.key});

  final Uint8List imageBytes;

  @override
  State<ProductImageCropPage> createState() => _ProductImageCropPageState();
}

class _ProductImageCropPageState extends State<ProductImageCropPage> {
  final CropController _cropController = CropController();
  var _isCropping = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Potong foto'),
      leading: IconButton(
        tooltip: 'Batal',
        onPressed: _isCropping ? null : () => Navigator.pop(context),
        icon: const Icon(Icons.close),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: Crop(
            image: widget.imageBytes,
            controller: _cropController,
            interactive: true,
            baseColor: Theme.of(context).colorScheme.surface,
            maskColor: Colors.black.withValues(alpha: 0.56),
            progressIndicator: const Center(child: CircularProgressIndicator()),
            onCropped: (result) {
              switch (result) {
                case CropSuccess(:final croppedImage):
                  Navigator.pop(context, croppedImage);
                case CropFailure(:final cause):
                  setState(() {
                    _isCropping = false;
                    _errorMessage = 'Foto gagal dipotong: $cause';
                  });
              }
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Geser bingkai untuk memilih area. Cubit foto untuk memperbesar atau memperkecil.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isCropping
                      ? null
                      : () {
                          setState(() {
                            _isCropping = true;
                            _errorMessage = null;
                          });
                          _cropController.crop();
                        },
                  icon: _isCropping
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.crop),
                  label: Text(
                    _isCropping ? 'Memotong foto...' : 'Gunakan foto',
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
