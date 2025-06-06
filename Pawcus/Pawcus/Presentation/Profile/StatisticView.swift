//
//  StatisticView.swift
//  Pawcus
//
//  Created by 김정원 on 6/6/25.
//

import Foundation
import SwiftUI

struct StatisticView: View {
    var body: some View {
        WebView(url: URL(string: "https://mvp-web-view.vercel.app")!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

import WebKit

struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("localStorage.helloworld = 'hello from macOS';")
        }
    }
}
