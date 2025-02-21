import 'package:flutter/material.dart';
import 'package:gismultiinstancetestingenvironment/pages/inbox.dart';
import 'package:gismultiinstancetestingenvironment/pages/riverbasin.dart';
import 'package:gismultiinstancetestingenvironment/pages/mappage.dart';
import 'package:gismultiinstancetestingenvironment/pages/emerg.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  // Create a GlobalKey for the Scaffold to manage the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      appBar: AppBar(
        backgroundColor: Color(0xFF213A57),
        title: Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Open the drawer when the hamburger icon is pressed
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications action
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Your Name'),
              accountEmail: Text('yourname@example.com'),
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
              title: Text('Account Settings'),
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
              leading: Icon(Icons.map_rounded),
              title: Text('Area Map'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AreaMapPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                // Handle Logout action
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPostCreateSection(),
            SizedBox(height: 20),
            _buildPostCard(
              name: 'Who Dini',
              timeAgo: '5 hours ago',
              content: 'Baha na jud guys',
              hasMedia: true,
            ),
            SizedBox(height: 20),
            _buildPostCard(
              name: 'John Doe',
              timeAgo: '2 hours ago',
              content: 'Pwede pud no pics just text.',
              hasMedia: false,
            ),
            SizedBox(height: 20),
            _buildPostCard(
              name: 'Kath Cath',
              timeAgo: '1 day ago',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.',
              hasMedia: true,
            ),
            SizedBox(height: 20),
            _buildPostCard(
              name: 'Khar Rhaan',
              timeAgo: 'Aug 24',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
              hasMedia: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCreateSection() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.clear),
            hintText: 'Type something here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            // Handle photo/video action
          },
          icon: Icon(Icons.photo, color: Colors.black),
          label: Text(
            'Photo',
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

  Widget _buildPostCard({
    required String name,
    required String timeAgo,
    required String content,
    required bool hasMedia,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300], // Placeholder for avatar
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF49454F),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Color(0xFF49454F)),
                  onPressed: () {
                    // Handle more action
                  },
                ),
              ],
            ),
            if (hasMedia) ...[
              SizedBox(height: 16),
              Container(
                height: 150,
                color: Colors.grey[300], // Placeholder for media
              ),
            ],
            SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF49454F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
