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
    _updateBackend();
  }

  Future<void> _updateBackend() async {
    final position = await ref.read(myLocationProvider.future);
    final myId = await ref.read(myIdProvider.future);
    if (myId != null) {
      await saveLocation(myId, position.latitude, position.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocationAsync = ref.watch(myLocationProvider);
    final partnerLocationAsync = ref.watch(partnerLocationProvider);
    final myIcon = ref.watch(myIconProvider).maybeWhen(
      data: (icon) => icon,
      orElse: () => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    final partnerIcon = ref.watch(partnerIconProvider).maybeWhen(
      data: (icon) => icon,
      orElse: () => BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );


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
                  builder: (context) => ChatScreen(),
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
              print("Partner Position: $partnerPosition");
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
                    icon: myIcon,
                    position: LatLng(myPosition.latitude, myPosition.longitude),
                    // onTap: FcmHandler().sendNotification
                  ),
                  if (partnerPosition != null)
                    Marker(
                      markerId: const MarkerId("partner_location"),
                      icon: partnerIcon,
                      position: LatLng(partnerPosition.latitude, partnerPosition.longitude),
                        onTap: (){ FcmHandler().sendVibrationNotification();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vibe sent successfully!"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
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
