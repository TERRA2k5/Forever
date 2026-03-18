import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/UI/ChatPage.dart';
import 'package:forever/providers/icon_provider.dart';
import 'package:forever/providers/id_provider.dart';
import 'package:forever/providers/my_location_provider.dart';
import 'package:forever/providers/partner_location_provider.dart';
import 'package:forever/fuctions/sql_functions.dart';
import 'package:forever/providers/pet_name_provider.dart';
import 'package:forever/services/fcm_handler.dart';
import 'package:forever/utils/alertboxes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/distance_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;

  // Helper to format distance nicely
  String _formatDistance(double? meters) {
    if (meters == null) return "Calculating...";
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    } else {
      return "${(meters / 1000).toStringAsFixed(2)} km";
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocationAsync = ref.watch(myLocationProvider);
    final partnerLocationAsync = ref.watch(partnerLocationProvider);
    final distance = ref.watch(distanceProvider);

    final myIcon = ref.watch(myIconProvider).maybeWhen(
      data: (icon) => icon,
      orElse: () => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    final partnerIcon = ref.watch(partnerIconProvider).maybeWhen(
      data: (icon) => icon,
      orElse: () => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );


    ref.listen(myLocationProvider, (previous, next) {
      next.whenData((position) async {
        final myId = ref.read(myIdProvider).value; // Assuming this is sync, or watch it
        if (myId != null) {
          await saveLocation(myId, position.latitude, position.longitude);
        }
      });
    });

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
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ));
              },
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
              if (partnerPosition == null) {
                Future.microtask(() {
                  if (context.mounted) showErrorBox(context, ref);
                });
                return const Center(child: CircularProgressIndicator());
              }

              final myLatLng = LatLng(myPosition.latitude, myPosition.longitude);
              final partnerLatLng = LatLng(partnerPosition.latitude, partnerPosition.longitude);

              return Stack(
                children: [
                  // 1. Map Layer
                  GoogleMap(
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: partnerLatLng,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) => _controller = controller,
                    markers: {
                      Marker(
                        markerId: const MarkerId("your_location"),
                        icon: myIcon,
                        position: myLatLng,
                      ),
                      Marker(
                        markerId: const MarkerId("partner_location"),
                        icon: partnerIcon,
                        position: partnerLatLng,
                        onTap: () {
                          FcmHandler().sendVibrationNotification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vibe sent successfully!"),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    },
                  ),

                  Positioned(
                    bottom: 90,
                    left: 10,
                    right: 80,
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Prevents stretching
                            children: [
                              Text(
                                  'Distance between you: ${_formatDistance(distance)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )
                              ),
                              const Text(
                                "(Tap partner to send vibe!)",
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          )
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 90,
                    right: 12,
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      shadowColor: Colors.black.withOpacity(0.15),
                      elevation: 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Button: Zoom to Me
                          IconButton(
                            padding: const EdgeInsets.all(12),
                            icon: Image.asset("assets/placement.png", width: 24, height: 24),
                            tooltip: "My Location",
                            onPressed: () {
                              _controller?.animateCamera(
                                CameraUpdate.newLatLngZoom(myLatLng, 15),
                              );
                            },
                          ),
                          Container(height: 1, width: 32, color: Colors.grey.shade300),

                          IconButton(
                            padding: const EdgeInsets.all(12),
                            icon: Image.asset("assets/heart.png", width: 24, height: 24),
                            tooltip: "Partner's Location",
                            onPressed: () {
                              _controller?.animateCamera(
                                CameraUpdate.newLatLngZoom(partnerLatLng, 15),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}