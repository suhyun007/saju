import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

void main() {
  runApp(const SajuWebViewApp());
}

class SajuWebViewApp extends StatelessWidget {
  const SajuWebViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사주 앱 (웹뷰)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    
    // 웹뷰 컨트롤러 초기화
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 로딩 진행률 업데이트
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('웹뷰 에러: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          // Flutter 앱과 웹뷰 간 통신
          print('웹뷰에서 받은 메시지: ${message.message}');
        },
      )
      ..loadRequest(Uri.parse('http://10.0.2.2:8080')); // 로컬 서버 URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사주 앱 (웹뷰)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await controller.canGoBack()) {
                controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await controller.canGoForward()) {
                controller.goForward();
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'home':
                  controller.loadRequest(Uri.parse('https://suhyuns-projects.vercel.app'));
                  break;
                case 'devtools':
                  _showDevToolsInfo();
                  break;
                case 'info':
                  _showAppInfo();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('홈으로'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'devtools',
                child: Row(
                  children: [
                    Icon(Icons.developer_mode),
                    SizedBox(width: 8),
                    Text('DevTools 정보'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('앱 정보'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('사주 앱 로딩 중...'),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '현재 URL: $currentUrl',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _showDevToolsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DevTools 사용법'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('웹뷰에서 DevTools를 사용하려면:'),
            SizedBox(height: 8),
            Text('1. 크롬에서 chrome://inspect 접속'),
            Text('2. "Discover USB devices" 체크'),
            Text('3. 디바이스에서 웹뷰 선택'),
            Text('4. "inspect" 클릭하여 DevTools 열기'),
            SizedBox(height: 8),
            Text('또는 웹뷰를 크롬에서 직접 열어서 F12 사용'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사주 앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Flutter 앱이 웹뷰로 감싸짐'),
            Text('✅ 크롬 DevTools로 디버깅 가능'),
            Text('✅ 모든 Flutter 기능 사용 가능'),
            Text('✅ 네이티브 앱과 웹뷰 간 통신 가능'),
            SizedBox(height: 8),
            Text('이 앱은 Flutter로 개발된 사주 앱을'),
            Text('웹뷰로 감싸서 모바일 앱처럼 사용할 수 있게'),
            Text('만든 것입니다.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
