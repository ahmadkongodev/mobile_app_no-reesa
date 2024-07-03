import 'package:flutter/material.dart';
import 'package:no_reesa/screens/home.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.blue,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
            children: [
             const  Text("Welcome to no-resa", style: TextStyle(color: Colors.white, fontSize: 30),),
             SizedBox(
              height: 200,
             ),
              ElevatedButton(onPressed: (){Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>   HomeScreen())  );}, child:Padding(
                padding: const EdgeInsets.all(15.0),
                child: const Icon(Icons.arrow_circle_right, size: 50,),
              ))
            ],
          ),
        ),
      ),
    );
  }
}