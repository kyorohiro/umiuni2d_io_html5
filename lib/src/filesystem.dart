part of umiuni2d_io_html5;

class FileSystem extends io.FileSystem {

  html.FileSystem _fileSystem;
  io.Entry _currentDirectory = null;

  Future<html.FileSystem> init() async {
    _fileSystem = await html.window.requestFileSystem(1024, persistent: true);
    return _fileSystem;
  }

  Future<io.FileSystem> checkPermission() async {
    Completer<io.FileSystem> ret = new Completer();
    html.window.navigator.persistentStorage.requestQuota(5 * 1024 * 1024, (a) {
      ret.complete(this);
    }, (b) {
      ret.completeError(b);
    });
    return ret.future;
  }

  Future<FileSystem> cd(String path) async {
    path = await toAbsoltePath(path);
    if(!await isDirectory(path)){
      throw "not directory ${path}";
    }
    html.FileSystem fs = await init();
    html.DirectoryEntry d = await fs.root.getDirectory(path);
    _currentDirectory = new Directory(d);
    return this;
  }

  Future<io.FileSystem> mkdir(String path) async {
    path = await toAbsoltePath(path);
    html.FileSystem fs = await init();
    html.Entry e = await fs.root.createDirectory(path, exclusive: false);
    print("## ${path} ${e.fullPath} ${e} isDir:${e.isDirectory}");
    return this;
  }

  Future<io.FileSystem> rm(String path,{bool recursive: false}) async {
    path = await toAbsoltePath(path);
   html.FileSystem fs = await init();
    try {
      html.FileEntry f  = await fs.root.getFile(path);
      f.remove();
    } catch(e) {
      html.Entry e = await fs.root.getDirectory(path);
      if(!e.isDirectory){
        throw "not found " + path;
      } else {
        html.DirectoryEntry d = await fs.root.getDirectory(path);
        if(recursive) {
          d.removeRecursively();
        } else {
          d.remove();
        }
      }
    }
    return this;
  }

  Future<bool> isFile(String path) async {
    path = await toAbsoltePath(path);
    html.FileSystem  fs = await init();
    try {
      html.Entry e = await fs.root.getFile(path);
      if(e.isFile) {
        return true;
      }
    } catch(e){
    }
    return false;
  }

  Future<bool> isDirectory(String path) async {
    path = await toAbsoltePath(path);
    html.FileSystem  fs = await init();
    try {
      html.Entry e = await fs.root.getDirectory(path);
      if(e.isDirectory) {
        return true;
      }
    } catch(e){
      print("EE ${e}");
    }
    return false;
  }

  Future<io.Entry> wd() async {
    if(_currentDirectory == null) {
      _currentDirectory = await getHomeDirectory();
    }
    return _currentDirectory;
  }

  Future<String> toAbsoltePath(String path) async {
    if(dpath.isAbsolute(path)) {
      return path;
    } else {
      //.replaceAll("file://", "")
      return dpath.normalize(dpath.joinAll([await (await wd()).path,path]));
    }
  }

  Stream<io.Entry> ls(String path) async* {
    path = await toAbsoltePath(path);
    html.FileSystem fs = await init();
    try {
      html.Entry f  = await fs.root.getFile(path);
      yield new File(f);
    } catch(e) {
      html.Entry e = await fs.root.getDirectory(path);
      if(!e.isDirectory){
        throw "not found " + path;
      } else {
        html.DirectoryEntry d = await fs.root.getDirectory(path);
        List<html.Entry> ds = await d.createReader().readEntries();
        for(html.Entry e in ds) {
          if(e.isDirectory) {
            yield new Directory(e);
          } else {
            yield new File(e);
          }
        }
      }
    }
  }

  Future<io.File> open(String path) async {
    path = await toAbsoltePath(path);
    html.FileSystem fs = await init();
    List<String> pat = path.split("/");
    String dir = "/";
    String fname = pat[pat.length-1];
    for(int i=0;i<pat.length -1;i++) {
      dir += pat[i]+"/";
    }
    html.DirectoryEntry ff = await fs.root.getDirectory(dir);
    return new File(await ff.createFile(fname, exclusive: false) as html.FileEntry) ;
  }

  Future<io.Entry> getHomeDirectory() async {
    html.FileSystem  fs = await init();
    return new Directory(fs.root);
  }
}