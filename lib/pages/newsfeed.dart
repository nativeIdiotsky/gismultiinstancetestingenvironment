import 'package:flutter/material.dart';
import 'package:gismultiinstancetestingenvironment/pages/createpost.dart';
import 'package:gismultiinstancetestingenvironment/pages/inbox/inbox_page.dart';
import 'package:gismultiinstancetestingenvironment/pages/index.dart';
import 'package:gismultiinstancetestingenvironment/pages/mapboxmap/mapboxmappage.dart';
import 'package:gismultiinstancetestingenvironment/pages/profilepage.dart';
import 'package:gismultiinstancetestingenvironment/pages/riverbasin.dart';
import 'package:gismultiinstancetestingenvironment/pages/newsfeed/post_card.dart';
import 'package:gismultiinstancetestingenvironment/pages/newsfeed/post_list.dart';
import 'package:gismultiinstancetestingenvironment/pages/emerg.dart';
import 'package:gismultiinstancetestingenvironment/pages/inbox/inbox_service_supa.dart';
import 'package:gismultiinstancetestingenvironment/pages/inbox/inbox_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final InboxService _inboxService = InboxService();
  List<NotifyBroadcast> _notifications = [];
  bool _isMounted = false; // ✅ Track widget state
  String? username = "Loading...";
  String? email = "Loading...";
  late Future<void> _refreshFuture;
  @override
  void initState() {
    super.initState();
    _isMounted = true; // ✅ Mark as mounted
    _refreshFuture = _fetchUserDetails();
    //   _setupNotifications();
    _fetchUserDetails();
  }

  void _setupNotifications() {
    _inboxService.subscribeToNotifications((newNotification) {
      if (!_isMounted) return; // ✅ Prevent calling setState() if disposed

      setState(() {
        _notifications.insert(0, newNotification);
      });

      _showSnackBar(newNotification.title); // 🔔 Show quick notification alert
    });
  }

// ✅ Fetch Current User Details from Supabase
  Future<void> _fetchUserDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // ✅ Check if the user is logged in anonymously
      if (user.email == null || user.email!.isEmpty) {
        setState(() {
          username = "Guest";
          email = "No Email";
        });
        return; // Exit early for anonymous users
      }

      // ✅ Fetch username & email for authenticated users
      final response = await Supabase.instance.client
          .from('profiles')
          .select('username, email')
          .eq('id', user.id)
          .single();

      if (response != null && _isMounted) {
        setState(() {
          username = response['username'] ?? "Unknown";
          email = response['email'] ?? "No Email";
        });
      }
    } catch (e) {
      print("❌ Error fetching user details: $e");
      if (_isMounted) {
        setState(() {
          username = "Error";
          email = "Failed to load";
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ✅ Show full notification list when bell icon is clicked
  void _showNotificationList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Notifications"),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _notifications
                .map((notification) => ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.description),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false; // ✅ Mark as unmounted
    super.dispose();
  }

  @override
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username ?? "Unknown"),
            accountEmail: Text(email ?? "No Email"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey[300],
            ),
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboxPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.local_drink),
            title: Text('River Basin Status'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiverBasinPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.phone_in_talk),
            title: Text('Emergency Hotline'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmergencyHotlinesPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Profile Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.map_rounded),
            title: Text('Jade Valley Area Map'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              _signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCreateSection() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePostScreen(),
              ),
            );
          },
          icon: Icon(Icons.photo, color: Colors.black),
          label: Text(
            'Create a Post',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final currentContext = context;
    await Supabase.instance.client.auth.signOut();

    if (currentContext.mounted) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => const Index(),
        ),
      );
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _refreshFuture = _fetchUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('News Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _showNotificationList,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _refreshPosts, // Call the refresh function
        child: FutureBuilder(
          future: _refreshFuture, // Ensure data is loaded
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: [
                _buildPostCreateSection(),
                PostList(), // Assuming PostList() displays posts
              ],
            );
          },
        ),
      ),
    );
  }
}
