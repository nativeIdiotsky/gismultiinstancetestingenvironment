import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:gismultiinstancetestingenvironment/pages/emerg.dart'; //Emergency hotlines
import 'package:gismultiinstancetestingenvironment/pages/inbox.dart'; //Inbox
import 'package:gismultiinstancetestingenvironment/pages/index.dart'; //Startup page
import 'package:gismultiinstancetestingenvironment/pages/mapbox.dart'; // Initial Mapbox page
import 'package:gismultiinstancetestingenvironment/pages/mapboxhand.dart'; //Raw area map with geolocation
import 'package:gismultiinstancetestingenvironment/pages/mappage.dart'; //Area map page
import 'package:gismultiinstancetestingenvironment/pages/newsfeed.dart'; //Main newsfeed page
import 'package:gismultiinstancetestingenvironment/pages/riverbasin.dart'; //Davao river basin status page

//import 'package:gismultiinstancetestingenvironment/pages/mappage.dart';
//import 'package:gismultiinstancetestingenvironment/pages/riverbasin.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
//import 'package:gismultiinstancetestingenvironment/pages/mapbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String SupabaseUrl = dotenv.env['SUPABASE_URL']!;
String SupabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance;
  await setup();
  await dotenv.load(fileName: 'assets/.env');

  // Await the initialization of Supabase
  await Supabase.initialize(
    url: SupabaseUrl,
    anonKey: SupabaseAnonKey,
  );
  runApp(const MyApp());
  print('Supabase URL: ${dotenv.env['SUPABASE_URL']}');
  print('Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']}');
}

bool envLoadedSuccessfully = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Index(),
    );
  }
}

Future<void> setup() async {
  try {
    await dotenv.load(fileName: 'assets/.env'); // Ensure the correct path

    if (dotenv.env['MAPBOX_ACCESS_TOKEN'] != null &&
        dotenv.env['MAPBOX_ACCESS_TOKEN']!.isNotEmpty) {
      envLoadedSuccessfully = true; // ✅ Flag for successful load
      print('✅ .env Loaded Successfully: $envLoadedSuccessfully');
    }
  } catch (e) {
    print('❌ Error loading .env file: $e');
  }

  // ✅ Ensure Mapbox is set after initialization
  if (envLoadedSuccessfully) {
    MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  } else {
    print('❌ Mapbox Access Token not found!');
  }
}
