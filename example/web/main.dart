import 'package:umiuni2d_io/umiuni2d_io.dart' as umi;
import 'package:umiuni2d_io_html5/umiuni2d_io.dart' as uni;

import 'dart:async';
import 'dart:html' as html;
import 'dart:convert' as conv;

Future main() async {
  print("Hellom World!!");
  umi.FileSystem fileSystem = new uni.FileSystem();
  await fileSystem.checkPermission();
  //console

  html.Element consoleElement = html.document.querySelector("#console");
  html.InputElement mkdirInputElement = html.document.querySelector("#mkdir_value");
  html.InputElement mkfileInputElement = html.document.querySelector("#mkfile_value");
  html.InputElement cdInputElement = html.document.querySelector("#cd_value");
  html.InputElement rmInputElement = html.document.querySelector("#rm_value");
  html.InputElement openInputElement = html.document.querySelector("#open_value");



  String getCurrentPlayerId() {
    if ((html.document.querySelector(
        "#bgm_maoudamashii_acoustic09") as html.InputElement).checked) {
      return "bgm_maoudamashii_acoustic09";
    } else {
      return "bgm_maoudamashii_lastboss0";
    }
  };

  lsFunc() async {
    print("ls");
    List<umi.Entry> entries = await fileSystem.ls("").toList();
    String v = "<div> len : ${entries.length}<br>";
    for(umi.Entry e in entries) {
      print("${e.path} ${await e.isDir()}");
      v += "${(await e.isDir()?"D":"F")} : ${e.path}<br>";
    }
    v += "</div>";
    consoleElement.innerHtml = v;
  };

  html.document
      .querySelector("#checkPermission")
      .onClick
      .listen((html.Event e) {
    print("CheckPermission");
    fileSystem.checkPermission();
    consoleElement.innerHtml = "";
  });

  html.document
      .querySelector("#ls")
      .onClick
      .listen((html.Event e) async {
    lsFunc();
  });

  html.document
      .querySelector("#wd")
      .onClick
      .listen((html.Event e) async {
    print("wd");
    umi.Entry e = await fileSystem.wd();
    print("${e.path}");
    consoleElement.innerHtml = "${e.path}";
  });

  html.document
      .querySelector("#mkdir")
      .onClick
      .listen((html.Event e) async {
    print("mkdir ${mkdirInputElement.value}");
    await fileSystem.mkdir(mkdirInputElement.value);
    lsFunc();
  });

  html.document
      .querySelector("#mkfile")
      .onClick
      .listen((html.Event e) async {
    print("+5s");
    umi.File f = await fileSystem.open(mkfileInputElement.value);
    List<int> buffer = conv.UTF8.encode("Hello, World!!");
    await f.writeAsBytes(buffer, 0);
    await f.close();
    lsFunc();

  });

  html.document
      .querySelector("#cd")
      .onClick
      .listen((html.Event e) async {
    print("cd ${cdInputElement.value};");
    await fileSystem.cd(cdInputElement.value);
    lsFunc();
  });

  html.document
      .querySelector("#rm")
      .onClick
      .listen((html.Event e) async {
    print("VolumeUp");
    await fileSystem.rm(rmInputElement.value,recursive: true);
    lsFunc();
  });

  html.document
      .querySelector("#open")
      .onClick
      .listen((html.Event e) async {
    print("open");
    umi.File f = await fileSystem.open(openInputElement.value);
    List<int> v = await f.readAsBytes(0, await f.getLength());
    String value = "";
    try {
      value = conv.UTF8.decode(v).replaceAll("\n", "<br>");
    } catch(e) {
      value = conv.BASE64.encode(v);
    }
    consoleElement.innerHtml ="<div>${value}</div>";
    f.close();
  });
}