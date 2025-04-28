import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharingService {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  // StreamController to notify listeners about shared files
  final _sharedFilesController = StreamController<List<SharedMediaFile>>.broadcast();
  Stream<List<SharedMediaFile>> get sharedFilesStream => _sharedFilesController.stream;

  // StreamController to notify listeners about shared text (URLs)
  final _sharedTextController = StreamController<String>.broadcast();
  Stream<String> get sharedTextStream => _sharedTextController.stream;

  void initialize() {
    // Listen to media sharing coming from outside the app while the app is in memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      _sharedFilesController.add(_sharedFiles); // Notify listeners
      print(_sharedFiles.map((f) => f.toMap()));

      // Check if the shared media contains a URL
      for (var file in value) {
        if (file.path.startsWith('http://') || file.path.startsWith('https://')) {
          _sharedTextController.add(file.path); // Notify listeners about shared URL
          print("Shared URL: ${file.path}");
        }
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      _sharedFilesController.add(_sharedFiles); // Notify listeners
      print(_sharedFiles.map((f) => f.toMap()));

      // Check if the initial shared media contains a URL
      for (var file in value) {
        if (file.path.startsWith('http://') || file.path.startsWith('https://')) {
          _sharedTextController.add(file.path); // Notify listeners about shared URL
          print("Initial shared URL: ${file.path}");
        }
      }

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }

  void dispose() {
    _intentSub.cancel();
    _sharedFilesController.close();
    _sharedTextController.close();
  }
}