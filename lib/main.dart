import 'dart:async';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter_blue/flutter_blue.dart';

//import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    stderr.writeln('Build MyApp.');
    developer.log('log me', name: 'dev log.');

    return MaterialApp(
      title: 'Learning Flutter with Bluetooth',
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
      ),
      home: ScanPage(title: 'Learning Flutter with BT'),
    );
  }
}

class ScanPage extends StatefulWidget {
  ScanPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  int _counter = 0;
  Random random = new Random();
  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> gscanResults = new Map();
  bool isScanning = false;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscription = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  // _scanSubscription = flutterBlue.scan().listen((scanResult) {
  //   // do something with scan result
  //   device = scanResult.device;
  //   print('${device.name} found! rssi: ${scanResult.rssi}');
  // });

  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();
  final TextStyle _biggerFont = TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    if (_flutterBlue.isOn == BluetoothState.off) {
      developer.log('Bluetooth state is off.', name: 'dev log.');
    } else if (_flutterBlue.isOn == true) {
      developer.log('Bluetooth state is on.', name: 'dev log.');
    }

    _flutterBlue.state.listen((s) {
      if (_flutterBlue.isOn == BluetoothState.off) {
        developer.log('Bluetooth state is off. 22', name: 'dev log.');
      } else if (_flutterBlue.isOn == true) {
        developer.log('Bluetooth state is on. 22', name: 'dev log.');
      }
      setState(() {
        state = s;
      });
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;

    _scanSubscription?.cancel();
    _scanSubscription = null;

    deviceConnection?.cancel();
    deviceConnection = null;

    super.dispose();
  }

  _startScan() {
    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((ScanResult scanResults) {
      print('localName : ${scanResults.advertisementData.localName}');
      print(
          'manufactureData : ${scanResults.advertisementData.manufacturerData}');
      print('service : ${scanResults.advertisementData.serviceData}');

      setState(() {
        print('${scanResults.device.name} found! rssi: ${scanResults.rssi}');
        gscanResults[scanResults.device.id] = scanResults;
      });
    }, onDone: _stopScan);

    setState(() {
      isScanning = true;
    });
  }

  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;

    setState(() {
      isScanning = false;
    });
  }

  _buildScanningButton() {
    if (isConnected || state != BluetoothState.on) {
      return null;
    }
    if (isScanning) {
      return FloatingActionButton(
        //child: Icon(Icon.stop),
        child: Icon(Icons.stop),
        onPressed: _stopScan,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
        child: Icon(
          Icons.search,
        ),
        onPressed: _startScan,
      );
    }
  }

  //https://www.youtube.com/watch?v=sJv1IPLfYdY&vl=ko 38:00

  Widget _buildSuggestions() {
    return Container(
      color: (Colors.yellow),
      child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: /*1*/ (context, i) {
            // stderr.writeln("i:"+ i)
            if (i.isOdd) return Divider(); /*2*/

            final index = i ~/ 2; /*3*/
            if (index >= _suggestions.length) {
              _suggestions.addAll(generateWordPairs().take(10)); /*4*/
            }
            return _buildRow(_suggestions[index]);
          }),
    );
  }

  String get6RandNum(){
    String ret="";
    for(var i=6; i>0; i--){
ret+=" "+(random.nextInt(45) + 1).toString();
    }
    return ret;
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return Container(
      color: (Colors.red),
      child: ListTile(
        title: Text(
          pair.asPascalCase + " " + get6RandNum() ,
          style: _biggerFont,
        ),
        trailing: Icon(
          // Add the lines from here...
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.pink[200] : null,
        ),
        onTap: () {
          // Add 9 lines from here...
          setState(() {
            if (alreadySaved) {
              _saved.remove(pair);
            } else {
              _saved.add(pair);
            }
          });
        },
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase + " " + (random.nextInt(45) + 1).toString(),
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

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
        // Here we take the value from the ScanPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('Lionel.j'),
              accountEmail: new Text('lionel.j@kakaocorp.com'),
              currentAccountPicture: new CircleAvatar(
                backgroundImage: new NetworkImage('http://i.pravatar.cc/300'),
              ),
            ),
            // DrawerHeader(
            //   child: Text("Drawer Header"),
            //   decoration: BoxDecoration(
            //     color: Colors.red,
            //   ),
            // ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
                _pushSaved();
              },
            ),
          ],
        ),
      ),

      /*
          
                body: Center(
                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.
                  child: Column(
                    // Column is also layout widget. It takes a list of children and
                    // arranges them vertically. By default, it sizes itself to fit its
                    // children horizontally, and tries to be as tall as its parent.
                    //
                    // Invoke "debug painting" (press "p" in the console, choose the
                    // "Toggle Debug Paint" action from the Flutter Inspector in Android
                    // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                    // to see the wireframe for each widget.
                    //
                    // Column has various properties to control how it sizes itself and
                    // how it positions its children. Here we use mainAxisAlignment to
                    // center the children vertically; the main axis here is the vertical
                    // axis because Columns are vertical (the cross axis would be
                    // horizontal).
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'You have pushed the button this many times:' +
                            WordPair.random().asPascalCase,
                      ),
                      Text((6 ~/ 2).toString()),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ],
                  ),
                ),
            */
      body: _buildSuggestions(),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: _buildScanningButton(),
    );
  }
}
