import 'package:flutter/material.dart';

class UserOrderScreen extends StatefulWidget {
  const UserOrderScreen({super.key});

  @override
  State<UserOrderScreen> createState() => _UserOrderScreenState();
}

class _UserOrderScreenState extends State<UserOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/noorder.png'),
              SizedBox(height: 10,),
              Text("No order history yet",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text("When you have Order done, you will see them here",style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: (){}, child: Text("Refresh"))
            ],
          ),
        ),
      )),
    );
  }
}
