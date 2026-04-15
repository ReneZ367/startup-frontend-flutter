import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class StubResponse {
  const StubResponse({
    required this.statusCode,
    this.body,
  });

  final int statusCode;
  final Object? body;
}

class StubHttpClientAdapter implements HttpClientAdapter {
  StubHttpClientAdapter(this._responsesByPath);

  final Map<String, List<StubResponse>> _responsesByPath;
  final Map<String, int> _indicesByPath = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final path = options.path;
    final responses = _responsesByPath[path] ?? _responsesByPath['*'];
    if (responses == null || responses.isEmpty) {
      throw StateError('No stubbed response for path: $path');
    }

    final index = _indicesByPath[path] ?? 0;
    final fallbackIndex = _indicesByPath['*'] ?? 0;
    final resolvedIndex = _responsesByPath[path] != null ? index : fallbackIndex;

    if (resolvedIndex >= responses.length) {
      throw StateError('No more stubbed responses for path: $path');
    }

    if (_responsesByPath[path] != null) {
      _indicesByPath[path] = resolvedIndex + 1;
    } else {
      _indicesByPath['*'] = resolvedIndex + 1;
    }

    final response = responses[resolvedIndex];
    final bytes = switch (response.body) {
      null => Uint8List(0),
      final String text => Uint8List.fromList(utf8.encode(text)),
      _ => Uint8List.fromList(utf8.encode(jsonEncode(response.body))),
    };

    return ResponseBody.fromBytes(
      bytes,
      response.statusCode,
      headers: const {'content-type': ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}
