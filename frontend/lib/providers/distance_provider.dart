import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/partner_location_provider.dart';
import 'package:geolocator/geolocator.dart';

import 'my_location_provider.dart';

final distanceProvider = Provider.autoDispose<double?>((ref) {
  final myPos = ref.watch(myLocationProvider).value;
  final partnerPos = ref.watch(partnerLocationProvider).value;

  if (myPos == null || partnerPos == null) return null;

  return Geolocator.distanceBetween(
    myPos.latitude,
    myPos.longitude,
    partnerPos.latitude,
    partnerPos.longitude,
  );
});