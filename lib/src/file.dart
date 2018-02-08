part of umiuni2d_io_html5;

class Directory extends io.Directory {
  html.Entry _fileEntry = null;

  Directory (this._fileEntry) {
  }
  String get name => _fileEntry.name;
  String get path => _fileEntry.fullPath;
  Future<bool> isFile() async {
    if(_fileEntry != null) {
      return _fileEntry.isFile;
    } else {
      return false;
    }

  }

  Future<bool> isDirectory() async {
    if(_fileEntry != null) {
      return _fileEntry.isDirectory;
    } else {
      return false;
    }
  }

  Future<bool> exists() async {
    if(_fileEntry != null) {
      return false;
    } else {
      return true;
    }
  }
}
class File extends io.File {
  html.FileEntry _fileEntry = null;

  File(this._fileEntry) {
  }

  String get name => _fileEntry.name;
  String get path => _fileEntry.fullPath;

  Future<bool> isFile() async {
    if(_fileEntry != null) {
      return _fileEntry.isFile;
    } else {
      return false;
    }

  }

  Future<bool> isDirectory() async {
    if(_fileEntry != null) {
      return _fileEntry.isDirectory;
    } else {
      return false;
    }
  }

  Future<bool> exists() async {
    if(_fileEntry != null) {
      return false;
    } else {
      return true;
    }
  }

  Future<int> writeAsBytes(List<int> buffer, int offset) async {
    if (!(buffer is Uint8List)) {
      buffer = new Uint8List.fromList(buffer);
    }

    Completer<int> completer = new Completer();
    html.FileWriter writer = await _fileEntry.createWriter();
    writer.onWrite.listen((html.ProgressEvent e) {
      completer.complete(buffer.length);
      writer.abort();
    });
    writer.onError.listen((e) {
      completer.completeError({});
      writer.abort();
    });
    int len = await getLength();
    if (len < offset) {
      Uint8List dummy = null;
      dummy = new Uint8List.fromList(new List.filled(offset - len, 0));
      writer.seek(len);
      writer.write(new html.Blob([dummy, buffer]).slice(0, buffer.length + dummy.length));
    } else {
      writer.seek(offset);
      writer.write(new html.Blob([buffer]).slice(0, buffer.length));
    }

    return completer.future;
  }

  Future<List<int>> readAsBytes(int offset, int length) async {
    Completer<List<int>> c_ompleter = new Completer();
    html.FileReader reader = new html.FileReader();
    html.File f = await _fileEntry.file();
    reader.onLoad.listen((_) {
      List<int> data = new List.from(reader.result);
      c_ompleter.complete(data);
    });
    reader.onError.listen((_) {
      c_ompleter.completeError(_);
    });
    reader.readAsArrayBuffer(f.slice(offset, offset + length));
    return c_ompleter.future;
  }

  Future<int> getLength() async {
    html.File f = await _fileEntry.file();
    return f.size;
  }

  Future<int> truncate(int fileSize) async {
    html.FileWriter writer = await _fileEntry.createWriter();
    writer.truncate(fileSize);
    return fileSize;
  }
}