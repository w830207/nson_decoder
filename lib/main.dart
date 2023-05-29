import 'dart:convert';
import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart' as ao;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _dragging = false;
  final List<XFile> _list = [];
  final TextEditingController textEditingController = TextEditingController();

  read(String path) async {
    if (path.endsWith("nson")) {
      final inputStream = ao.InputFileStream(path);
      final inflate = ao.Inflate.stream(inputStream);
      textEditingController.text = utf8.decode(inflate.getBytes());
    } else if (path.endsWith("json")) {
      textEditingController.text = await File(path).readAsString();
    } else {
      _list.clear();
    }
    setState(() {});
  }

  popJson() async {
    String? path = await getSavePath(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'json', extensions: ['json'])
      ],
      suggestedName: 'default.json',
    );
    if (path?.isEmpty ?? false) return;
    saveJson(path!);
  }

  popNson() async {
    String? path = await getSavePath(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'nson', extensions: ['nson'])
      ],
      suggestedName: 'default.nson',
    );
    if (path?.isEmpty ?? false) return;
    saveNson(path!);
  }

  saveJson(String path) async {
    if (textEditingController.text.isEmpty) return;
    await File(path).writeAsString(textEditingController.text);
    reset();
  }

  saveNson(String path) async {
    if (textEditingController.text.isEmpty) return;
    final bytes = utf8.encode(textEditingController.text);
    final outputBytes = ZLibEncoder(raw: true, windowBits: 15).convert(bytes);
    await File(path).writeAsBytes(outputBytes);
    reset();
  }

  reset() {
    _dragging = false;
    _list.clear();
    textEditingController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _list.isEmpty
            ? Visibility(
                visible: _list.isEmpty,
                child: DropTarget(
                  onDragDone: (detail) {
                    setState(() {
                      _list.addAll(detail.files);
                    });

                    if (_list.isNotEmpty) {
                      read(_list.first.path);
                    }
                  },
                  onDragEntered: (detail) {
                    setState(() {
                      _dragging = true;
                    });
                  },
                  onDragExited: (detail) {
                    setState(() {
                      _dragging = false;
                    });
                  },
                  child: Container(
                    height: 200,
                    width: 200,
                    color: _dragging
                        ? Colors.blue.withOpacity(0.4)
                        : Colors.black26,
                    child: const Center(child: Text("Drop here")),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                      onPressed: popJson, child: const Text("save json")),
                  TextButton(
                      onPressed: popNson, child: const Text("save nson")),
                  TextButton(onPressed: reset, child: const Text("reset")),
                  TextField(
                    controller: textEditingController,
                    maxLines: null,
                  ),
                ],
              ),
      ),
    );
  }
}
