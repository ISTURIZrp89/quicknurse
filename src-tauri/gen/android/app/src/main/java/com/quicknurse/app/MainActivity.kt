package com.quicknurse.app

import android.os.Bundle
import android.webkit.WebView
import org.tauri.TauriActivity

class MainActivity : TauriActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Configure WebView settings for clinical app
        val webView = findViewById<WebView>(org.tauri.R.id.webview)
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            setAppCacheEnabled(true)
            cacheMode = WebView.LOAD_DEFAULT
            mixedContentMode = android.webkit.WebSettings.MIXED_CONTENT_NEVER_ALLOW
        }
    }
}