import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Web server running on http://localhost:8080');

  await for (HttpRequest request in server) {
    await handleRequest(request);
  }
}

Future<void> handleRequest(HttpRequest request) async {
  final path = request.uri.path;
  
  try {
    if (path == '/' || path == '/home') {
      await serveFile(request, 'web/home_screen.html', 'text/html');
    } else if (path == '/saju_input') {
      await serveFile(request, 'web/saju_input.html', 'text/html');
    } else if (path.startsWith('/web/')) {
      final filePath = path.substring(1); // Remove leading '/'
      await serveFile(request, filePath, getContentType(filePath));
    } else {
      await serve404(request);
    }
  } catch (e) {
    print('Error serving $path: $e');
    await serve404(request);
  }
}

Future<void> serveFile(HttpRequest request, String filePath, String contentType) async {
  final file = File(filePath);
  
  if (await file.exists()) {
    request.response
      ..headers.contentType = ContentType.parse(contentType)
      ..headers.add('Access-Control-Allow-Origin', '*')
      ..headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..headers.add('Access-Control-Allow-Headers', 'Content-Type')
      ..write(await file.readAsString())
      ..close();
  } else {
    await serve404(request);
  }
}

Future<void> serve404(HttpRequest request) async {
  request.response
    ..statusCode = HttpStatus.notFound
    ..write('File not found')
    ..close();
}

String getContentType(String filePath) {
  if (filePath.endsWith('.html')) return 'text/html';
  if (filePath.endsWith('.css')) return 'text/css';
  if (filePath.endsWith('.js')) return 'application/javascript';
  if (filePath.endsWith('.png')) return 'image/png';
  if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) return 'image/jpeg';
  return 'text/plain';
}
