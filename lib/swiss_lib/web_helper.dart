import 'package:flutter/services.dart';
import 'package:sweph/sweph.dart';

class _WebAssetLoader implements AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    try {
      ByteData data = await rootBundle.load('assets/$assetPath');
      return data.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to load asset: $assetPath - $e');
    }
  }
}

Future<void> initSweph([List<String> epheAssets = const []]) async {
  await Sweph.init(
    epheAssets: epheAssets,
    epheFilesPath: 'assets/ephe', // Adjust this based on asset location
    assetLoader: _WebAssetLoader(),
  );
}
