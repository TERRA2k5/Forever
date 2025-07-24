import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/fuctions/sql_functions.dart';
import 'package:forever/providers/id_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fuctions/geolocator_functions.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;
  Position? _myPosition;
  Position? _partnerPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getString('my_id');
    final partnerId = prefs.getString('partner_id');
    final myPosition = await getCurrentLocation();
    final partnerPosition = await fetchLocation(partnerId!);
    setState(() {
      _myPosition = myPosition;
      _partnerPosition = partnerPosition;
    });

    await saveLocation(myId!, myPosition!.latitude, myPosition!.longitude);
    await saveLocation(
      partnerId!,
      partnerPosition!.latitude,
      partnerPosition!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body:
          _partnerPosition == null && _myPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _partnerPosition!.latitude,
                    _partnerPosition!.longitude,
                  ),
                  zoom: 15,
                ),
                onMapCreated: (controller) => _controller = controller,
                markers: {
                  Marker(
                    markerId: const MarkerId("your_location"),
                    position: LatLng(
                      _myPosition!.latitude,
                      _myPosition!.longitude,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId("partner_location"),
                    position: LatLng(
                      _partnerPosition!.latitude,
                      _partnerPosition!.longitude,
                    ),
                  ),
                },
              ),
    );
  }
}
