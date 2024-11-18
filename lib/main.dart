import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          initAsync();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
  }

  initAsync() async {
    try {
      var shell = Shell();
      await shell.run('''
      su -c ls /data
      ''');
      print("已经获得root");

      const searchPath = '/data/data/com.tencent.mm';
      const appPrivatePath = '/data/data/com.fuckguetsign.app.fuck_guet_sign/files';

     //  var result = await shell.run('''
     // su -c "ls -a ${searchPath}"
    // ''') ;
    // //   var result = await shell.run('''
    //   su -c "id"
    //   su -c "setenforce 0"
    //   su -c "ls -a /data/data/com.tencent.mm"
    // ''') ;
    //   print(result.map((e)=>e.outText));

      await findAndCopyCookies(searchPath, appPrivatePath);

      // 搜索所有 Cookies 文件
      // final cookiesFiles = await findAllCookiesFiles(Directory(searchPath));
      //
      // if (cookiesFiles.isNotEmpty) {
      //   print('Found ${cookiesFiles.length} Cookies file(s):');
      //   for (var file in cookiesFiles) {
      //     print(file.path);
      //   }
      // } else {
      //   print('No Cookies files found.');
      // }

    } catch (e) {
      print(e);
    }
  }
}

Future<List<File>> findAllCookiesFiles(Directory directory) async {
  List<File> cookiesFiles = [];

  try {
    // 检查目录是否存在
    if (!await directory.exists()) {
      print('Directory does not exist: ${directory.path}');
      return cookiesFiles;
    }

    // 获取目录下的文件和子目录
    final contents = directory.listSync();

    for (var entity in contents) {
      if (entity is File) {
        print(entity);
        // 检查文件名是否是 `Cookies`
        if (entity.path.endsWith('Cookies')) {
          print('Found Cookies file: ${entity.path}');
          cookiesFiles.add(entity);
        }
      } else if (entity is Directory) {
        // 递归遍历子目录
        var subDirectoryFiles = await findAllCookiesFiles(entity);
        cookiesFiles.addAll(subDirectoryFiles);
      }
    }
  } catch (e) {
    print('Error while searching: $e');
  }

  return cookiesFiles;
}

/// 搜索并拷贝所有 `Cookies` 文件到应用目录
Future<void> findAndCopyCookies(String searchPath, String appPrivatePath) async {
  // 使用 Shell 实例来运行命令
  var shell = Shell();

  try {
    // 确保应用私有目录存在
    final targetDir = Directory(appPrivatePath);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // 使用 find 命令查找 Cookies 文件
    var result = await shell.run('''
      su -c "find $searchPath -type f -name 'Cookies'"
    ''');

    // 收集找到的文件路径
    var output = result.first.stdout.trim();
    print(output);
    if (output.isNotEmpty) {
      // 拆分为每个文件路径
      final files = output.toString().split('\n').where((path) => path.isNotEmpty);
      print('Found Cookies files: ${files.join(', ')}');

      // 循环拷贝每个文件
      for (final filePath in files) {
        final fileName = filePath.split('/').last;
        final targetPath = '$appPrivatePath/$fileName-${DateTime.timestamp().millisecondsSinceEpoch}';

        // 拷贝文件到目标目录
        await shell.run('''
          su -c "cp $filePath $targetPath"
        ''');

        print('Copied: $filePath to $targetPath');
      }
    } else {
      print('No Cookies files found in $searchPath');
    }
  } catch (e) {
    print('Error during operation: $e');
  }
}