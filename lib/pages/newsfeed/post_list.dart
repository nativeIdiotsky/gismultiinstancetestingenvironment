import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'post_card.dart';

class PostList extends StatefulWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select(
              'postid, post_header, post_body, post_image_url, posted_at, profiles(username)')
          .order('posted_at', ascending: false);
      // print(response);
      setState(() {
        posts = response;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                name: post['username'] ??
                    post['profiles']?['username'] ??
                    'Unknown User', // Access inside profiles// Use username from query
                timeAgo: DateFormat('MMM d, y hh:mm a')
                    .format(DateTime.parse(post['posted_at'])),
                postHeader: post['post_header'] ?? 'No title available',
                postBody: post['post_body'] ?? 'No content available',
                imageUrl: post['post_image_url'],
              );
            },
          );
  }
}
