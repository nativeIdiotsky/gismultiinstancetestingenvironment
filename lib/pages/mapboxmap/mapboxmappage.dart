import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geoloc;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;

  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF213A57),
        title: const Text(
          'Jade Valley Map',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: MapboxStyles.OUTDOORS,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: "Focus on device location",
                  child: FloatingActionButton(
                    heroTag: 'focus_location',
                    onPressed: focusOnUserLocation,
                    child: const Icon(Icons.my_location),
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Tooltip(
                  message: "Pin the desired location",
                  child: FloatingActionButton(
                    heroTag: 'pin_location',
                    onPressed: focusOnUserLocation,
                    child: const Icon(Icons.location_pin),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    try {
      // ✅ Load the GeoJSON file from assets
      String geoJsonString =
          await rootBundle.loadString('assets/jadevalley.geojson');
      Map<String, dynamic> geoJsonData = json.decode(geoJsonString);

      // ✅ Extract polygon bounds
      List coordinates = geoJsonData['features'][0]['geometry']['coordinates']
          [0]; // First polygon
      double minLng = coordinates[0][0];
      double minLat = coordinates[0][1];
      double maxLng = minLng;
      double maxLat = minLat;

      for (var coord in coordinates) {
        double lng = coord[0];
        double lat = coord[1];
        if (lng < minLng) minLng = lng;
        if (lat < minLat) minLat = lat;
        if (lng > maxLng) maxLng = lng;
        if (lat > maxLat) maxLat = lat;
      }

      // ✅ Set camera bounds (restrict movement outside this bounding box)
      await mapboxMapController?.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            infiniteBounds: false, // Enforce bounds restriction
            southwest: Point(coordinates: Position(minLng, minLat)),
            northeast: Point(coordinates: Position(maxLng, maxLat)),
          ),
          maxZoom: 18.0, // Allow zooming in
          minZoom: 12.0, // Prevent zooming out too much
        ),
      );

      // ✅ Add GeoJSON Source
      await mapboxMapController?.style.addSource(GeoJsonSource(
        id: "mask-source",
        data: geoJsonString,
      ));

      // ✅ Apply a LineLayer for borders
      await mapboxMapController?.style.addLayer(LineLayer(
        id: "border-layer",
        sourceId: "mask-source",
        lineColor: Colors.red.value,
        lineWidth: 1.5,
      ));

      // ✅ Enable User Location with Pulsing Effect
      await mapboxMapController?.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
        ),
      );

      print("✅ Map with bounds restriction loaded successfully");
    } catch (e) {
      print("❌ Error loading GeoJSON or updating map: $e");
    }
  }

  Future<void> _setupPositionTracking() async {
    bool serviceEnabled = await geoloc.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    geoloc.LocationPermission permission =
        await geoloc.Geolocator.checkPermission();
    if (permission == geoloc.LocationPermission.denied) {
      permission = await geoloc.Geolocator.requestPermission();
      if (permission == geoloc.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == geoloc.LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    geoloc.LocationSettings locationSettings = geoloc.LocationSettings(
      accuracy: geoloc.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream =
        geoloc.Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((geoloc.Position? position) {
      if (position != null && mapboxMapController != null) {
        mapboxMapController?.setCamera(
          CameraOptions(
            zoom: 15,
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
          ),
        );
        print(
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      }
    });
  }

  Future<void> focusOnUserLocation() async {
    try {
      geoloc.Position position = await geoloc.Geolocator.getCurrentPosition(
        desiredAccuracy: geoloc.LocationAccuracy.high,
      );
      if (mapboxMapController != null) {
        mapboxMapController?.setCamera(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 15,
          ),
        );
        print(
            "Focused on user: Lat=${position.latitude}, Lng=${position.longitude}");
      }
    } catch (e) {
      print("Error getting user location: $e");
    }
  }
}
