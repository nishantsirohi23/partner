import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWithMarker extends StatelessWidget {
  final LatLng fixedLocation; // Define a fixed location

  GoogleMapWithMarker({required this.fixedLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: fixedLocation, // Use the fixed location as the initial camera position
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            // You can perform additional operations when the map is created if needed
          },
          markers: {
            Marker(
              markerId: MarkerId("fixedLocationMarker"),
              position: fixedLocation,
            ),
          },
        ),
      ),
    );
  }
}
