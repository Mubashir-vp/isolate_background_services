// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

void myIsolate(SendPort isolateToMainStream) {
  ReceivePort mainToIsolateStream = ReceivePort();
  isolateToMainStream.send(mainToIsolateStream.sendPort);
  mainToIsolateStream.listen((data) {
    log('[mainToIsolateStream] $data');
    exit(0);
  });
  isolateToMainStream.send('This is from myIsolate');
}

Future initIsolate() async {
  Completer completer = Completer<SendPort>();
  ReceivePort isolateToMainStream = ReceivePort();
  isolateToMainStream.listen((data) {
    if (data is SendPort) {
      SendPort mainToIsolateStream = data;
      completer.complete(mainToIsolateStream);
    } else {
      log('[isolateToMainStream] $data');
    }
  });
  await Isolate.spawn(myIsolate, isolateToMainStream.sendPort);
  return completer.future;
}

void main() async {
  SendPort mainToIsolateStream = await initIsolate();
  mainToIsolateStream.send('Notification');
}
