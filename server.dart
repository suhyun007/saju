import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('서버가 http://:8080 에서 실행 중입니다.');
  print('웹뷰 앱에서 이 주소로 접속하세요.');

  await for (HttpRequest request in server) {
    await handleRequest(request);
  }
}

Future<void> handleRequest(HttpRequest request) async {
  try {
    final path = request.uri.path;
    final file = File('build/web$path');
    
    if (await file.exists()) {
      final content = await file.readAsBytes();
      final contentType = _getContentType(path);
      
      request.response
        ..headers.contentType = contentType
        ..headers.add('Access-Control-Allow-Origin', '*')
        ..headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        ..headers.add('Access-Control-Allow-Headers', 'Content-Type')
        ..add(content)
        ..close();
    } else {
      // index.html로 리다이렉트
      final indexFile = File('build/web/index.html');
      if (await indexFile.exists()) {
        final content = await indexFile.readAsBytes();
        request.response
          ..headers.contentType = ContentType.html
          ..headers.add('Access-Control-Allow-Origin', '*')
          ..add(content)
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('404 - 파일을 찾을 수 없습니다.')
          ..close();
      }
    }
  } catch (e) {
    print('에러: $e');
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write('500 - 서버 에러')
      ..close();
  }
}

ContentType _getContentType(String path) {
  if (path.endsWith('.html')) return ContentType.html;
  if (path.endsWith('.js')) return ContentType.parse('application/javascript');
  if (path.endsWith('.css')) return ContentType.parse('text/css');
  if (path.endsWith('.png')) return ContentType.parse('image/png');
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return ContentType.parse('image/jpeg');
  if (path.endsWith('.gif')) return ContentType.parse('image/gif');
  if (path.endsWith('.svg')) return ContentType.parse('image/svg+xml');
  if (path.endsWith('.json')) return ContentType.json;
  if (path.endsWith('.woff')) return ContentType.parse('font/woff');
  if (path.endsWith('.woff2')) return ContentType.parse('font/woff2');
  if (path.endsWith('.ttf')) return ContentType.parse('font/ttf');
  return ContentType.text;
}
