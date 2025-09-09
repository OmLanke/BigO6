import 'package:flutter/material.dart';

class CopyrightsPage extends StatelessWidget {
  final String copyrightsText;
  
  const CopyrightsPage({
    super.key, 
    required this.copyrightsText,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TomTom Maps API - Copyrights"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20), 
                  child: Text(
                    copyrightsText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
