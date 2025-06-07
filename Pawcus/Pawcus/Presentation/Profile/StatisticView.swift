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
        WebView(url: URL(string: "https://mvp-web-view.vercel.app/test")!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

import WebKit

struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "tokenHandler")
        config.userContentController = contentController

        // Enable Web Inspector (developer mode)
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.preferences = preferences

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

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("localStorage.helloworld = 'hello from macOS';")
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "tokenHandler" {
                if let body = message.body as? [String: Any],
                   let type = body["type"] as? String,
                   type == "request_token" {

                    let accessToken = KeychainHelper.standard.read(service: "com.pawcus.token", account: "accessToken") ?? "no_access_token"
                    let refreshToken = KeychainHelper.standard.read(service: "com.pawcus.token", account: "refreshToken") ?? "no_refresh_token"

                    let script = """
                        if (window.receiveTokenFromSwift) {
                            window.receiveTokenFromSwift('\(accessToken)', '\(refreshToken)');
                        }
                    """

                    DispatchQueue.main.async {
                        message.webView?.evaluateJavaScript(script, completionHandler: nil)
                    }
                }
            }
        }
    }
}
