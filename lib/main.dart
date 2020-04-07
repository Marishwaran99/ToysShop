import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Josefin',
        textTheme: TextTheme(
          headline:TextStyle(fontSize:24, fontWeight:FontWeight.bold),
          title:TextStyle(fontSize:18, fontWeight:FontWeight.bold),
          subtitle: TextStyle(fontSize:16, fontWeight:FontWeight.w600,color:Color(0xff222222)),
          body1:TextStyle(fontSize:16, color: Color(0xff333333)),
          body2:TextStyle(fontSize:14, color: Color(0xff333333)),
          caption:TextStyle(fontSize:12, color: Color(0xff222222)),
        )
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Products'),
      ),
      body: SingleChildScrollView(
        
        child:Container(
          padding:EdgeInsets.symmetric(horizontal:16, vertical:24),
        child:Text('hello world')
      )
    ));
  }
}
