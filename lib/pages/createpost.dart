import 'package:flutter/material.dart';
import 'package:gismultiinstancetestingenvironment/pages/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _postHeaderController = TextEditingController();
  final _postBodyController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _username;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final User? user = supabase.auth.currentUser;
    final Map<String, dynamic>? metadata = user?.userMetadata;

    if (user != null) {
      final postData = await supabase
          .from('posts')
          .select('posted_at, post_header, post_body')
          .eq('user_id', user.id)
          .order('posted_at', ascending: false);

      setState(() {
        if (metadata != null) {
          _username = metadata['display_name'];
        }
        _posts = postData as List<dynamic>;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitPost() async {
    final User? user = supabase.auth.currentUser;
    final currentContext = context;
    final header = _postHeaderController.text.trim();
    final body = _postBodyController.text.trim();

    if (user != null) {
      await supabase.from('posts').insert(
        {
          'user_id': user.id,
          'post_header': header,
          'post_body': body,
        },
      );
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Post successfully posted.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    _fetchUserData();
  }

  Future<void> _signOut() async {
    final currentContext = context;
    await supabase.auth.signOut();

    if (currentContext.mounted) {
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => const Index(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _postHeaderController.dispose();
    _postBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Display the username
                  Text(
                    'Hello, ${_username ?? 'User'}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Input fields for post creation
                  TextField(
                    controller: _postHeaderController,
                    decoration: InputDecoration(labelText: 'Set a header'),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _postBodyController,
                    decoration:
                        InputDecoration(labelText: 'What\'s on your mind'),
                  ),
                  SizedBox(height: 20),

                  // Buttons for submitting and signing out
                  ElevatedButton(
                    onPressed: _submitPost,
                    child: Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: Text('Sign Out'),
                  ),
                  SizedBox(height: 20),

                  // Display the user's posts
                  Expanded(
                    child: _posts.isEmpty
                        ? Text('No posts yet')
                        : ListView.builder(
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  title: Text(post['post_header']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(post['post_body']),
                                      SizedBox(height: 5),
                                      Text(
                                        'Posted at: ${post['posted_at']}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
