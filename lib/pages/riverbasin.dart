import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

class RiverBasinPage extends StatefulWidget {
  @override
  _RiverBasinPageState createState() => _RiverBasinPageState();
}

class _RiverBasinPageState extends State<RiverBasinPage> {
  List<String> floodAlerts = [];
  bool isLoading = true;
  bool _isMounted = false; // ✅ Track widget lifecycle

  @override
  void initState() {
    super.initState();
    _isMounted = true; // ✅ Mark as mounted
    fetchFloodData();
  }

  Future<void> fetchFloodData() async {
    if (!_isMounted) return; // ✅ Prevent unnecessary calls if unmounted

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("http://192.168.1.6:2120/api/flood/davao");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        final alertElements =
            document.querySelectorAll("h2, p, .alert, .warning");

        if (!_isMounted) return; // ✅ Check before calling setState()
        setState(() {
          floodAlerts = alertElements
              .map((e) => e.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();
        });
      } else {
        if (!_isMounted) return;
        setState(() {
          floodAlerts = ["Failed to fetch data."];
        });
      }
    } catch (error) {
      if (!_isMounted) return;
      setState(() {
        floodAlerts = ["Error: ${error.toString()}"];
      });
    } finally {
      if (!_isMounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false; // ✅ Mark as unmounted
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F2FA),
        title: Text(
          'River Basin Status',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            color: Color(0xFF1D1B20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1D1B20)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'STATUS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF49454F),
                  letterSpacing: 0.25,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFB3E5FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      floodAlerts.isNotEmpty
                          ? floodAlerts.join("\n")
                          : "No flood alerts available.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
            SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213A57),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              onPressed: fetchFloodData,
              child: Text(
                'REFRESH',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
