import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/partner_location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'distance_provider.dart';
import 'my_location_provider.dart';

Future<BitmapDescriptor> getResizedMarker(String assetPath, int width) async {
  final ByteData data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  final fi = await codec.getNextFrame();
  final bytes = await fi.image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

final myIconProvider = FutureProvider<BitmapDescriptor>((ref) async {
  final distance = ref.watch(distanceProvider);

  if(distance == 50000.0){
    return await getResizedMarker('assets/babypink', 100);
  }
  return await getResizedMarker('assets/placement.png', 100);
});

final partnerIconProvider = FutureProvider<BitmapDescriptor>((ref) async {
  final distance = ref.watch(distanceProvider);

  if(distance == 50000.0){
    return await getResizedMarker('assets/babypink_partner', 100);
  }

  return await getResizedMarker('assets/heart.png', 100);
});
