import 'package:flutter/material.dart';
import 'inbox_card.dart';
import 'inbox_service_supa.dart';
import 'inbox_model.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final InboxService _inboxService = InboxService();
  late Future<List<NotifyBroadcast>> _notifications;
  List<NotifyBroadcast> _notificationList = [];
  bool _isMounted = false; // ✅ Track if the widget is mounted

  @override
  void initState() {
    super.initState();
    _isMounted = true; // ✅ Mark as mounted
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _inboxService.fetchNotifications();
    });
    _notifications.then((list) {
      if (_isMounted) {
        setState(() {
          _notificationList = list;
        });
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false; // ✅ Mark as unmounted
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemHeight = screenWidth * 0.2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF213A57),
        title: const Text(
          'Inbox',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _notificationList.isEmpty
            ? const Center(child: Text('No messages available.'))
            : ListView.builder(
                itemCount: _notificationList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      height: itemHeight,
                      child: InboxCard(notification: _notificationList[index]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
