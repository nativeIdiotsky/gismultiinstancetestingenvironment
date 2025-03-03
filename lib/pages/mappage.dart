import 'package:flutter/material.dart';
import 'mapboxhand.dart';

class AreaMapPage extends StatefulWidget {
  @override
  _AreaMapPageState createState() => _AreaMapPageState();
}

class _AreaMapPageState extends State<AreaMapPage> {
  final GlobalKey<MapboxhandState> mapKey = GlobalKey<MapboxhandState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF213A57),
        title: Text(
          'Area Map',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Mapboxhand(key: mapKey), // Corrected usage
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message:
                      "Focus on device location", // Text to show on tap and hold
                  child: FloatingActionButton(
                    heroTag: 'focus_location',
                    onPressed: () {
                      mapKey.currentState?.focusOnUserLocation();
                    },
                    child: Icon(Icons.my_location),
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Tooltip(
                  message:
                      "Pin the desired location", // Text to show on tap and hold
                  child: FloatingActionButton(
                    heroTag: 'pin_location',
                    onPressed: () {
                      mapKey.currentState?.focusOnUserLocation();
                    },
                    child: Icon(Icons.location_pin),
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
}
