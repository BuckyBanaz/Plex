import 'package:flutter/material.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({super.key});

  @override
  State<UserNotification> createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/notification.png'),
              SizedBox(height: 10,),
              Text("No notifications yet",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text("When you have notification, you will see them here",style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: (){}, child: Text("Refresh"))
            ],
          ),
        ),
      )),
    );
  }
}
