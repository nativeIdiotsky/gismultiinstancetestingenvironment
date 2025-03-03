import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import App Screens
import 'package:gismultiinstancetestingenvironment/pages/emerg.dart';
import 'package:gismultiinstancetestingenvironment/pages/inbox/inbox_page.dart';
import 'package:gismultiinstancetestingenvironment/pages/index.dart';
import 'package:gismultiinstancetestingenvironment/pages/mapbox.dart';
import 'package:gismultiinstancetestingenvironment/pages/mapboxhand.dart';
import 'package:gismultiinstancetestingenvironment/pages/mappage.dart';
import 'package:gismultiinstancetestingenvironment/pages/newsfeed.dart';
import 'package:gismultiinstancetestingenvironment/pages/riverbasin.dart';

/// Supabase Credentials
String SupabaseUrl = dotenv.env['SUPABASE_URL']!;
String SupabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

/// Firebase Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Setup Firebase Cloud Messaging (FCM)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Load Environment Variables
  await dotenv.load(fileName: 'assets/.env');

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: SupabaseUrl,
    anonKey: SupabaseAnonKey,
  );

  // ✅ Initialize Local Notifications
  _setupLocalNotifications();

  // ✅ Store FCM Token in Supabase
  await storeFCMToken();

  // ✅ Start App
  runApp(const MyApp());
}

/// Background message handler for FCM
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Received a background message: ${message.messageId}");
}

/// Main App Entry Point
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

/// ✅ Request Notification Permissions & Retrieve FCM Token
Future<void> storeFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission from the user
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted notification permission');

    // Retrieve the FCM Token
    String? token = await messaging.getToken();
    print('🔑 FCM Token: $token');

    // ✅ Store the FCM token in Supabase
    if (token != null) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles') // Ensure this matches your table
            .update({'fcm_token': token}).eq('id', user.id);
        print('✅ FCM Token stored in Supabase');
      } else {
        print('⚠️ No authenticated user found in Supabase');
      }
    }
  } else {
    print('❌ User denied notification permission');
  }
}

/// ✅ Setup Local Notifications
void _setupLocalNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

/// ✅ Show Local Notification when FCM Message Arrives
Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? "New Alert",
    message.notification?.body ?? "You have a new message",
    notificationDetails,
  );
}

/// ✅ Setup Mapbox Access Token
Future<void> setup() async {
  try {
    await dotenv.load(fileName: 'assets/.env'); // Ensure correct path

    if (dotenv.env['MAPBOX_ACCESS_TOKEN'] != null &&
        dotenv.env['MAPBOX_ACCESS_TOKEN']!.isNotEmpty) {
      print('✅ .env Loaded Successfully');
      MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
    } else {
      print('❌ Mapbox Access Token not found!');
    }
  } catch (e) {
    print('❌ Error loading .env file: $e');
  }
}
