//
//  StatisticView.swift
//  Pawcus
//
//  Created by 김정원 on 6/6/25.
//

import Foundation
import SwiftUI
import WebKit

struct StatisticView: View {
    var body: some View {
        WebView(url: URL(string: "https://mvp-web-view.vercel.app/leaderboard")!)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // WebView에서 Swift로 메시지를 받기 위한 핸들러 추가
        contentController.add(context.coordinator, name: "pawcusHandler")
        config.userContentController = contentController
        
        // 개발자 도구 활성화
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
        
        // 페이지 로드 완료 시 초기 토큰 전달
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 액세스 토큰 가져오기
             let accessToken = TokenManager.getAccessToken()
            
            // WebView에 초기 토큰 전달
            let script = "window.initAccessToken('\(accessToken)')"
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error initializing access token: \(error)")
                } else {
                    print("Successfully initialized access token in WebView")
                }
            }
        }
        
        // WebView로부터 메시지 수신
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "pawcusHandler" {
                if let body = message.body as? [String: Any],
                   let type = body["type"] as? String {
                    
                    switch type {
                    case "request_token":
                        handleTokenRequest(message.webView)
                    default:
                        print("Unknown message type: \(type)")
                    }
                }
            }
        }
        
        // 토큰 요청 처리
        private func handleTokenRequest(_ webView: WKWebView?) {
            guard let webView = webView else { return }
            
            // 현재 액세스 토큰 가져오기
            let accessToken = TokenManager.getAccessToken()
              
            // 토큰 응답 전송 - 웹뷰가 요청한 형식에 맞게 응답
            let responseScript = """
            {
                const token = '\(accessToken)';
                console.log('Sending token to WebView:', token);
                
                // 여러 방법으로 토큰 전달
                if (window.tokenReceived) {
                    window.tokenReceived({ accessToken: token });
                }
                
                // postMessage 방식
                if (window.postMessage) {
                    window.postMessage({ type: 'token_response', accessToken: token }, '*');
                }
                
                // 전역 변수에도 저장
                window.__accessToken = token;
            }
            """
            
            DispatchQueue.main.async {
                webView.evaluateJavaScript(responseScript) { result, error in
                    if let error = error {
                        print("Error sending token response: \(error)")
                    } else {
                        print("Successfully sent token response")
                    }
                }
            }
        }
    }
}
