import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharingService {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  // StreamController to notify listeners about shared files
  final _sharedFilesController = StreamController<List<SharedMediaFile>>.broadcast();
  Stream<List<SharedMediaFile>> get sharedFilesStream => _sharedFilesController.stream;

  void initialize() {
    // Listen to media sharing coming from outside the app while the app is in memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      _sharedFilesController.add(_sharedFiles); // Notify listeners
      print(_sharedFiles.map((f) => f.toMap()));
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      _sharedFilesController.add(_sharedFiles); // Notify listeners
      print(_sharedFiles.map((f) => f.toMap()));

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }

  void dispose() {
    _intentSub.cancel();
    _sharedFilesController.close();
  }
}