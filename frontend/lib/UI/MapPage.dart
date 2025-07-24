import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/my_location_provider.dart';
import 'package:forever/providers/partner_location_provider.dart';
import 'package:forever/fuctions/sql_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    _saveMyLocationToBackend();
  }

  Future<void> _saveMyLocationToBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getString('my_id');
    final position = await ref.read(myLocationProvider.future);
    if (myId != null) {
      await saveLocation(myId, position.latitude, position.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocationAsync = ref.watch(myLocationProvider);
    final partnerLocationAsync = ref.watch(partnerLocationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Forever",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: myLocationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error myPosition: $err")),
        data: (myPosition) {
          return partnerLocationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text("Error partnerPosition: $err")),
            data: (partnerPosition) {
              return GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: partnerPosition != null
                      ? LatLng(partnerPosition.latitude, partnerPosition.longitude)
                      : LatLng(myPosition.latitude, myPosition.longitude),
                  zoom: 15,
                ),
                onMapCreated: (controller) => _controller = controller,
                markers: {
                  Marker(
                    markerId: const MarkerId("your_location"),
                    position: LatLng(myPosition.latitude, myPosition.longitude),
                  ),
                  if (partnerPosition != null)
                    Marker(
                      markerId: const MarkerId("partner_location"),
                      position: LatLng(partnerPosition.latitude, partnerPosition.longitude),
                    ),
                },
              );
            },
          );
        },
      ),
    );
  }
}
