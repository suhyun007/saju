package com.example.saju_app

import android.os.Bundle
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // WebView 디버깅 활성화
        WebView.setWebContentsDebuggingEnabled(true)
    }
}