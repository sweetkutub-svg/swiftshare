import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../../core/constants.dart';
import '../../core/logger.dart';
import 'receiver_page_handler.dart';

class LocalHttpServer {
  final _logger = AppLogger.instance;
  HttpServer? _server;

  Future<void> start() async {
    try {
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(ReceiverPageHandler.handle);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, AppConstants.localHttpPort);
      _logger.i('Local HTTP server started on port ${AppConstants.localHttpPort}');
    } catch (e) {
      _logger.e('Local HTTP server failed to start', e: e);
    }
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _logger.i('Local HTTP server stopped');
  }
}
