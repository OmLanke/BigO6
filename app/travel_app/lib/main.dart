import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Travel App'), centerTitle: true),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Image(image: AssetImage("assets/Kiryu.jpg"))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('BAKA MITAI'), Icon(Icons.person)],
            ),
          ],
        ),
      ),
    );
  }
}
