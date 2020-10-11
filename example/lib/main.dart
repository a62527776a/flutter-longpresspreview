import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:long_press_preview/index.dart';

import './card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onCreateDialog() async {}

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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, //横轴三个子widget
              childAspectRatio: 0.6 //宽高比为1时，子widget
              ),
          itemCount: 24,
          itemBuilder: (BuildContext context, int idx) {
            return Container(
                child: LongPressPreview(
                    onCreateDialog: () => onCreateDialog(),
                    dialogSize: const Size(300, 300),
                    onContentTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen())),
                    child: MediaCardVertical(imageUrl: 'assets/example.jpg', title: 'BiliBili 干杯🍻', scope: 3),
                    content: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          AspectRatio(
                              aspectRatio: 158 / 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset('assets/unnamed1.jpg'),
                              )),
                          SizedBox(height: 16),
                          const ListTile(
                            leading: Icon(Icons.album),
                            title: Text('The Enchanted Nightingale'),
                            subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: const Text('BUY TICKETS'),
                                onPressed: () {/* ... */},
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                child: const Text('LISTEN'),
                                onPressed: () {/* ... */},
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    )));
          }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Second Screen"),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            // Navigate back to first screen when tapped!
          },
          child: new Text('Go back!'),
        ),
      ),
    );
  }
}
